From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 1 Dec 2015 14:31:10 -0800
Message-ID: <20151201143110.39ec3e99@xeon-e3>
References: <20151201080652.5cba6f8b@xeon-e3>
	<20151201.142847.1980856920707150414.davem@davemloft.net>
	<20151201122038.795305df@xeon-e3>
	<20151201.155725.733555238839381632.davem@davemloft.net>
	<1449004499.3829359.455124521.608D0A9E@webmail.messagingengine.com>
	<20151201134407.3018adcc@xeon-e3>
	<1449006894.3839234.455160217.6BE59AFD@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, max@rfc2324.org,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35321 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757188AbbLAWbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 17:31:02 -0500
Received: by pacej9 with SMTP id ej9so18627252pac.2
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 14:31:01 -0800 (PST)
In-Reply-To: <1449006894.3839234.455160217.6BE59AFD@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 01 Dec 2015 22:54:54 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> 
> On Tue, Dec 1, 2015, at 22:44, Stephen Hemminger wrote:
> > On Tue, 01 Dec 2015 22:14:59 +0100
> > Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > > I had several snmp installations with net-snmp and munin, cacti and so
> > > on and all had the interface name in ifDescription already some years
> > > back.
> > 
> > In net-snmp 5.7 or later ifDescr is set to result of pci_lookup_name
> > (by default).
> 
> Seems the data should simply be in ifName nowadays (unconfirmed):
> <http://www.net-snmp.org/docs/mibs/ifMIBObjects.html>
> 
> Bye,
> Hannes

By default
  ifDescr == ifName == interface name (ie eth0, enp0s1, ...)
If the device is on PCI bus then result is like:


IF-MIB::ifDescr.2 = STRING: Realtek Semiconductor Co., Ltd. RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller
IF-MIB::ifName.2 = STRING: enp3s0
