From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] should we care of COMPAT mode in bridge ?
Date: Tue, 7 Jun 2011 16:51:34 -0700
Message-ID: <20110607165134.3e20bb9b@s6510.ftrdhcpuser.net>
References: <1307389540.2642.3.camel@edumazet-laptop>
	<20110606.130309.847468074358617705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46676 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757043Ab1FGXvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 19:51:35 -0400
In-Reply-To: <20110606.130309.847468074358617705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 Jun 2011 13:03:09 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 06 Jun 2011 21:45:40 +0200
> 
> > While trying Alexander Holler patch, I found a 32bit brctl program was
> > not able to work on a 64bit kernel. So I had to switch to another
> > machine for my tests.
> > 
> > brctl addbr mybridge
> > ->
> > socket(PF_FILE, SOCK_STREAM, 0)         = 3
> > ioctl(3, SIOCSIFBR, 0xffd509c0)         = -1 EINVAL (Invalid argument)
> > 
> > Should we care or not ?
> 
> I think we should make an effort to fix this.

The problem is that most of the other ioctl's won't work because of use of
SIOCDEVPRIVATE.
