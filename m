From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Default Route Support on Router
Date: Sun, 29 Sep 2002 00:47:05 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209282047.AAA03890@sex.inr.ac.ru>
References: <20020928.151959.131438421.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, davem@redhat.com (Dave Miller)
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.ORG (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20020928.151959.131438421.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Sep 28, 2 10:45:00 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Following patch is against linux-2.4.19.

OK!


One question, what is this chunk for?

> @@ -675,7 +690,7 @@
>  
>  	fn = fib6_lookup_1(root, args);
>  
> -	if (fn == NULL)
> +	if (fn == NULL || fn->fn_flags & RTN_TL_ROOT)
>  		fn = root;
>  
>  	return fn;

Alexey
