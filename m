From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [net-2.6.22] [TCP]: Fix linkage errors.
Date: Tue, 24 Apr 2007 20:17:46 +0200
Message-ID: <20070424181746.GP3468@stusta.de>
References: <20070425.001743.19811068.yoshfuji@linux-ipv6.org> <20070424155324.GL3468@stusta.de> <20070424180348.2d40fbcb.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: YOSHIFUJI Hideaki / ____________ <yoshfuji@linux-ipv6.org>,
	davem@davemloft.net, shemminger@osdl.org, netdev@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:33040 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1422823AbXDXSRf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 14:17:35 -0400
Content-Disposition: inline
In-Reply-To: <20070424180348.2d40fbcb.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 24, 2007 at 06:03:48PM +0200, Eric Dumazet wrote:
> On Tue, 24 Apr 2007 17:53:24 +0200
> Adrian Bunk <bunk@stusta.de> wrote:
> > Couldn't this be better solved by adding something like the following 
> > to include/linux/ktime.h ?
> > 
> > static inline s64 ktime_to_us(const ktime_t kt)
> > {
> >    return (s64) kt.tv.sec * USEC_PER_SEC + kt.tv.nsec / NSEC_PER_USEC;
> > }
> > 
> 
> Please check again include/linux/ktime.h
> 
> tv struct is defined inside 'ktime_t' only if BITS_PER_LONG != 64 && !defined(CONFIG_KTIME_SCALAR)

That's the difference between a "what about" suggestion and an actual 
patch...

I was merely suggesting solvin it through a ktime_to_us(), not 
presenting a complete and tested patch.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

