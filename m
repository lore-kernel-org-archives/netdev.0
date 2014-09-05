From: Dan Williams <dcbw@redhat.com>
Subject: Re: Does NetworkManager kill IPv6 connections?
Date: Fri, 05 Sep 2014 13:42:25 -0500
Message-ID: <1409942545.15943.10.camel@dcbw.local>
References: <063D6719AE5E284EB5DD2968C1650D6D174876CB@AcuExch.aculab.com>
	 <1409854625.23720.7.camel@dcbw.local>
	 <063D6719AE5E284EB5DD2968C1650D6D1748838C@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62943 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751481AbaIESm3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 14:42:29 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1748838C@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-05 at 14:18 +0000, David Laight wrote:
> From: Dan Williams 
> > On Thu, 2014-09-04 at 14:47 +0000, David Laight wrote:
> > > I was running a overnight test that failed because an (almost idle) IPv6 connection
> > > unexpectedly disconnected.
> > > 30 seconds before the disconnect syslog contains (retyped):
> > >   NetworkManager[pid]: <info> policy set 'Wired connection 2' (eth0) as default for IPv6 routing and DNS.
> > > The same message appeared exactly 70 minutes earlier - with no ill effect.
> > > A second connection between the same pair if addresses (carrying a lot of traffic)
> > > was unaffected.
> > >
> > > Any idea what/why NetworkManager is doing?
> > > (Yes I know it is userspace, but it seems to be breaking the kernel....)
> > >
> > > The system is an ubuntu 13.04 desktop (3.8.0-19 kernel), that recent, but
> > > newer than the ones a lot of our customers use.
> > 
> > Is the version of the Ubuntu "network-manager" package on your systems
> > 0.9.8.0-0ubuntu6.1?
> 
> It is actually the slightly older 0.9.8.0-0ubuntu6.0
> 
> > If so, I know we've fixed a ton of issues with IPv6 since 0.9.8.0 (which
> > was released about 18 months ago), and the ones that may be affecting
> > you are related to router advertisement timing and expiry.  The latest
> > stable NM version upstream is 0.9.10 and should contain all of those
> > fixes.
> 
> I've flagged it with our management, they'll decide what to say
> about IPv6 support in various Linux distros.

Ok, keep me (and the NM upstream) in the loop depending on what gets
decided.  Like I said, subsequent stable versions of NetworkManager in
recent distros have much improved IPv6 support, and if you have a chance
to try it out and let me know how it goes, that would be awesome.

Dan

> 	David
> 
> > Since I'm pretty sure this isn't a kernel problem, would you mind
> > discussing this over on the NM lists here:
> > 
> > https://mail.gnome.org/mailman/listinfo/networkmanager-list
> > 
> > If you don't want to subscribe that's fine, I'll moderate your message
> > through and we can just use "reply all".
> > 
> > Thanks,
> > Dan
> > 
> > > I can rerun the test, but don't know what to look for.
> > > 'eth0' is the only ethernet interface in the system that is actually
> > > connected to a network.
> > >
> > > Some indications of where to look would be appreciated.
> > >
> > > 	David
> > >
> > >
> > >
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
