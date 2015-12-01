From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 1 Dec 2015 13:44:07 -0800
Message-ID: <20151201134407.3018adcc@xeon-e3>
References: <20151201080652.5cba6f8b@xeon-e3>
	<20151201.142847.1980856920707150414.davem@davemloft.net>
	<20151201122038.795305df@xeon-e3>
	<20151201.155725.733555238839381632.davem@davemloft.net>
	<1449004499.3829359.455124521.608D0A9E@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, max@rfc2324.org,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33007 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756544AbbLAVn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 16:43:58 -0500
Received: by pabfh17 with SMTP id fh17so18069892pab.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 13:43:58 -0800 (PST)
In-Reply-To: <1449004499.3829359.455124521.608D0A9E@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Dec 2015 22:14:59 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Tue, Dec 1, 2015, at 21:57, David Miller wrote:
> > From: Stephen Hemminger <stephen@networkplumber.org>
> > Date: Tue, 1 Dec 2015 12:20:38 -0800
> > 
> > > On Tue, 01 Dec 2015 14:28:47 -0500 (EST)
> > > David Miller <davem@davemloft.net> wrote:
> > > 
> > >> From: Stephen Hemminger <stephen@networkplumber.org>
> > >> Date: Tue, 1 Dec 2015 08:06:52 -0800
> > >> 
> > >> > On Tue, 01 Dec 2015 17:02:23 +0100
> > >> > Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > >> > 
> > >> >> On Tue, Dec 1, 2015, at 16:50, Maximilian Wilhelm wrote:
> > >> >> > > I'm not sure I understand how this would work- are we going to 
> > >> >> > > pin down the ifindex for some subset of interfaces?
> > >> >> > 
> > >> >> > I'm not sure what your idea is, but I guess we might mean the same
> > >> >> > thing:
> > >> >> > 
> > >> >> > What I have in mind is that the user can supply a list of (ifname ->
> > >> >> > ifindex) entries via a sysfs/procfs interface and if such a list is
> > >> >> > present, the kernel will search the list for every ifname which is
> > >> >> > registered and check if there is an entry. If there is, the ifindex
> > >> >> > for this entry is used. If there is no entry found for the given
> > >> >> > ifname, the usual algorithm is used (therefore inherently providing
> > >> >> > backward compatibility).
> > >> >> 
> > >> >> Sorry to ask because I don't like this feature at all. There was a lot
> > >> >> of work on stable interface names. Why do you need stable ifindexes,
> > >> >> which were never meant to be stable for a longer amount of time?
> > >> > 
> > >> > Also current versions of SNMP provide more useful information about
> > >> > network interface slot information in ifDescription
> > >> 
> > >> Well if they do provide strings, then that is probably a better way
> > >> forward than messing with the kernel.
> > > 
> > > It gives strings based on PCI information but nothing useful
> > > on tunnels.
> > 
> > But at least in theory, that could be extended to do so right?
> 
> I had several snmp installations with net-snmp and munin, cacti and so
> on and all had the interface name in ifDescription already some years
> back.

In net-snmp 5.7 or later ifDescr is set to result of pci_lookup_name
(by default).
