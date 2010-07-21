From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] net: dsa: introduce MICREL
 KSZ8893MQL/BL ethernet switch chip support
Date: Wed, 21 Jul 2010 10:23:38 -0700 (PDT)
Message-ID: <20100721.102338.160104305.davem@davemloft.net>
References: <1279719442-10174-1-git-send-email-vapier@gentoo.org>
	<1279719442-10174-2-git-send-email-vapier@gentoo.org>
	<20100721151608.GM21121@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: karl.beldan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        graf.yang-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
In-Reply-To: <20100721151608.GM21121-SHk0+jKqY/D5VnbZ9m/NDkB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <https://blackfin.uclinux.org/mailman/options/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <https://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Date: Wed, 21 Jul 2010 17:16:08 +0200

> On Wed, Jul 21, 2010 at 09:37:22AM -0400, Mike Frysinger wrote:
> 
>> +#define pr_fmt(fmt) "ksz8893m: " fmt
> 
> This has no users.

egrep pr_fmt include/linux/kernel.h

It feeds into all of the various kernel logging interfaces.
