From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Netlink, route monitoring, RTM_DELROUTE not issued for ppp peer
 address. Bug or feature?
Date: Mon, 16 Apr 2012 12:29:48 -0700
Message-ID: <20120416122948.3b8c5272@s6510.linuxnetplumber.net>
References: <8986ed37b55c756ecdeec0315f73e63a@visp.net.lb>
	<023e01cd197d$a9faba40$fdf02ec0$@no>
	<3db49d4a58321a5e185cd67335a60c81@visp.net.lb>
	<20120416.144005.2201460378756236307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, stian@nixia.no, eric.dumazet@gmail.com,
	stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49534 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab2DPT3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2012 15:29:51 -0400
In-Reply-To: <20120416.144005.2201460378756236307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 16 Apr 2012 14:40:05 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Denys Fedoryshchenko <denys@visp.net.lb>
> Date: Mon, 16 Apr 2012 13:37:14 +0300
> 
> > So the only solution is to fetch first, then keep full routing table
> > in userspace also, and keep tracking if local addresses deleted, and
> > do the same in userspace and check for prefsrc...
> 
> You don't need to keep full routing table in userspace, don't be
> silly.

Quagga does (in multiple daemons) and uses this to manage
route distribution and recursive routes.

> You only need to watch for the device down event, and purge in
> userspace based upon that key.
