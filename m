From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH] Fix build errors on 32bit platforms with new ktime
Date: Tue, 24 Apr 2007 20:19:15 +0200
Message-ID: <20070424181915.GQ3468@stusta.de>
References: <20070425.001743.19811068.yoshfuji@linux-ipv6.org> <20070424155324.GL3468@stusta.de> <20070425.005845.113682267.yoshfuji@linux-ipv6.org> <20070425.011028.113320997.yoshfuji@linux-ipv6.org> <20070424183827.adb60ae0.dada1@cosmosbay.com> <20070424100420.2860db68@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	davem@davemloft.net, netdev@vger.kernel.org, tglx@linutronix.de
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:33053 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1422987AbXDXSTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 14:19:04 -0400
Content-Disposition: inline
In-Reply-To: <20070424100420.2860db68@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 24, 2007 at 10:04:20AM -0700, Stephen Hemminger wrote:
>...
> +/**
> + * ktime_to_us - convert a ktime_t variable to scalar microseconds
> + * @kt:		the ktime_t variable to convert
> + *
> + * Returns the scalar nanoseconds representation of @kt
> + */
> +static inline s64 ktime_to_us(const ktime_t kt)
> +{
> +	return (s64) kt.tv_sec * USEC_PER_SEC + kt.tv_nsec / NSEC_PER_USEC;
>...                 kt.tv.sec                  kt.tv.nsec

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

