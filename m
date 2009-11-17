From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Mon, 16 Nov 2009 22:02:47 -0800
Message-ID: <20091116220247.564fb0b6@nehalam>
References: <4AFBD911.6000900@gmail.com>
	<4AFCE273.7010901@gmail.com>
	<20091116083905.634b8f56@nehalam>
	<20091116.191054.131722163.davem@davemloft.net>
	<412e6f7f0911162138k6537afd1l5f8eeeaa6c636289@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38178 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227AbZKQGC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 01:02:57 -0500
In-Reply-To: <412e6f7f0911162138k6537afd1l5f8eeeaa6c636289@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 13:38:29 +0800
Changli Gao <xiaosuo@gmail.com> wrote:

> On Tue, Nov 17, 2009 at 11:10 AM, David Miller <davem@davemloft.net> wrote:
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Mon, 16 Nov 2009 08:39:05 -0800
> >
> >> My $.02 is that receive packet steering RPS should be done generically at
> >> receive layer. Then all the CPU, mapping and configuration issues can be
> >> done once, not just for IFB, Bridge, VLAN, ... The number of users of IFB
> >> is small, and setup is complex. Steering packets in IFB is optimizing only
> >> a rarely used corner.
> >>
> >> Layered link services like IFB need to be multi-threaded lockless to maintain
> >> the advantages of multi-queue and RPS.
> >
> > You're probably right.
> >
> 
> So I have to wait RPS, and after it gets merged, I'll back with
> multi-threaded lockless IFB.

Please don't wait... Help, test it make sure it works.
