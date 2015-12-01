From: Maximilian Wilhelm <max@rfc2324.org>
Subject: Re: [RFC] Stable interface index option
Date: Tue, 1 Dec 2015 17:10:25 +0100
Message-ID: <20151201161025.GC14984@principal.rfc2324.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.rfc2324.org ([31.172.8.67]:39636 "EHLO mail.rfc2324.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754297AbbLAQK1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 11:10:27 -0500
Received: from rfc2324.org ([31.172.8.84] helo=principal.rfc2324.org)
	by mail.rfc2324.org with esmtp rfc2324.org Mailserver
	id 1a3nVa-0005p1-2G
	for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 17:10:26 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anno domini 2015 Hannes Frederic Sowa scripsit:

> On Tue, Dec 1, 2015, at 16:50, Maximilian Wilhelm wrote:
> > > I'm not sure I understand how this would work- are we going to 
> > > pin down the ifindex for some subset of interfaces?
> > 
> > I'm not sure what your idea is, but I guess we might mean the same
> > thing:
> > 
> > What I have in mind is that the user can supply a list of (ifname ->
> > ifindex) entries via a sysfs/procfs interface and if such a list is
> > present, the kernel will search the list for every ifname which is
> > registered and check if there is an entry. If there is, the ifindex
> > for this entry is used. If there is no entry found for the given
> > ifname, the usual algorithm is used (therefore inherently providing
> > backward compatibility).

> Sorry to ask because I don't like this feature at all. There was a lot
> of work on stable interface names. Why do you need stable ifindexes,
> which were never meant to be stable for a longer amount of time?

As described in my first mail, there currently is a real-world problem
with snmp based monitoring of linux network devices. As snmp is the de
facto standard for monitoring of network devices this presents a
problem when working with the according tools (traffic graphs aren't
accurent or have to be changed manually on daily basis, weathermaps
aren't correct like show to few traffic or the "wrong" one, etc.)

So this is the most simple and most generic approach to fix this
problem.

What's the reason you don't like this feature at all?

Best
Max
-- 
     "really soon now":      an unspecified period of time, likly to
                             be greater than any reasonable definition
                             of "soon".
