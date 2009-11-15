From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Sun, 15 Nov 2009 12:19:14 +1030
Message-ID: <20091115121914.07adaee0@opy.nosense.org>
References: <20091113233504.GQ19478@kvack.org>
	<20091113153924.6130135f@nehalam>
	<20091113235210.GR19478@kvack.org>
	<20091113.185937.251557071.davem@davemloft.net>
	<20091115090604.331d75c2@opy.nosense.org>
	<20091114172224.5ca4c94e@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bcrl@lhnet.ca,
	opurdila@ixiacom.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:43969 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751611AbZKOBtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 20:49:19 -0500
In-Reply-To: <20091114172224.5ca4c94e@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Nov 2009 17:22:24 -0800
Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Sun, 15 Nov 2009 09:06:04 +1030
> Mark Smith <lk-netdev@lk-netdev.nosense.org> wrote:
> 
> > The fundamental purpose of PPPoE is nothing to do with any scaling or
> > architecture, it is purely to make a more modern shared networking
> > technology like Ethernet look like high speed dial up. This has occurred
> > mainly because when broadband came along it allowed ISPs to introduce
> > it quickly, without having to also upgrade their dial up oriented
> > backend systems i.e. customer authentication/accounting and customer
> > support systems. It wasn't ideal then and it isn't ideal now. PPPoE adds
> > an overhead of 8 bytes per packet, yet the only thing it is doing is
> > changing ethernet from multipoint to point-to-point so PPP can run
> > over it and providing ISPs with an ability to identify the subscriber.
> > There are other methods to solve customer identity problem without the
> > PPPoE overheads. Moving to them however can be a long drawn out process
> > because it also means changes to customer's CPE settings, or running
> > the old and new methods in parallel for the foreseeable future.
> 
> Carriers still haven't figured out that circuit switched networks don't
> scale. They just can't learn the lesson of the Internet.

I don't really think that is the case. The authors of the PPPoE
spec were all from "Internet" companies, including UUNET, the first
Internet company, and the largest at the time, so I'm sure they all knew
about Internet scaling.

Here's what they had to say in the RFC2516 intro:

"  Modern access technologies are faced with several conflicting goals.
   It is desirable to connect multiple hosts at a remote site through
   the same customer premise access device.  It is also a goal to
   provide access control and billing functionality in a manner similar
   to dial-up services using PPP.  In many access technologies, the most
   cost effective method to attach multiple hosts to the customer
   premise access device, is via Ethernet.  In addition, it is desirable
   to keep the cost of this device as low as possible while requiring
   little or no configuration."


