From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: Re: [PATCH] Kernel oops in ip6t_LOG.c:ip6_nexthdr
Date: Thu, 26 Aug 2004 20:56:45 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040826.205645.45258047.yoshfuji@wide.ad.jp>
References: <20040826113538.GE15409@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: okir@suse.de, netdev@oss.sgi.com
In-Reply-To: <20040826113538.GE15409@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040826113538.GE15409@suse.de> (at Thu, 26 Aug 2004 13:35:39 +0200), Olaf Kirch <okir@suse.de> says:

>                         hdrlen = *hdrptr[1] * 8 + 8;
> 			         ^^^^^^^^^^ it dies here
>                         *hdrptr = *hdrptr + hdrlen;
>                         break;
> 
> hdrptr is a u_int8_t **. What you really want to do here is
> look at (*hdrptr)[1], but what the expression does is look at
> *(hdrptr[1]). Unfortunately, hdrptr[1] is usually random garbage.

Agreed. Same bug also lives in 2.4.x.

--yoshfuji
