From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [net-2.6.22] [TCP]: Fix linkage errors.
Date: Tue, 24 Apr 2007 18:03:48 +0200
Message-ID: <20070424180348.2d40fbcb.dada1@cosmosbay.com>
References: <20070425.001743.19811068.yoshfuji@linux-ipv6.org>
	<20070424155324.GL3468@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki / =?ISO-8859-1?B?X19fX19fX19fX19f?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	shemminger@osdl.org, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:43279 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161775AbXDXQDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 12:03:54 -0400
In-Reply-To: <20070424155324.GL3468@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Apr 2007 17:53:24 +0200
Adrian Bunk <bunk@stusta.de> wrote:
> Couldn't this be better solved by adding something like the following 
> to include/linux/ktime.h ?
> 
> static inline s64 ktime_to_us(const ktime_t kt)
> {
>    return (s64) kt.tv.sec * USEC_PER_SEC + kt.tv.nsec / NSEC_PER_USEC;
> }
> 

Please check again include/linux/ktime.h

tv struct is defined inside 'ktime_t' only if BITS_PER_LONG != 64 && !defined(CONFIG_KTIME_SCALAR)

