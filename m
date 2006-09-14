From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH]:[XFRM] BEET mode
Date: Wed, 13 Sep 2006 20:14:23 -0700
Message-ID: <20060913201423.06990b98.rdunlap@xenotime.net>
References: <1158164779.4508312bab9c2@webmail.hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org, miika@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:58508 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1751089AbWINDNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2006 23:13:12 -0400
Received: from midway.site ([71.117.233.155]) by xenotime.net for <netdev@vger.kernel.org>; Wed, 13 Sep 2006 20:13:11 -0700
To: Diego Beltrami <Diego.Beltrami@hiit.fi>
In-Reply-To: <1158164779.4508312bab9c2@webmail.hiit.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 13 Sep 2006 19:26:19 +0300 Diego Beltrami wrote:

Looks like IMP (? or something else along the way?) split a long line
into 2 lines for you (same thing in 2 places).  See below.


> diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
> new file mode 100644
> index 0000000..75db6a6
> --- /dev/null
> +++ b/net/ipv4/xfrm4_mode_beet.c
> @@ -0,0 +1,139 @@

> + * The top IP header will be constructed per
> draft-nikander-esp-beet-mode-06.txt.

There, above, and same comment in the ipv6 source file.

> diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
> new file mode 100644
> index 0000000..edcfffa
> --- /dev/null
> +++ b/net/ipv6/xfrm6_mode_beet.c
> @@ -0,0 +1,107 @@
> +
> +/* Add encapsulation header.
> + *
> + * The top IP header will be constructed per
> draft-nikander-esp-beet-mode-06.txt.

There, above.

> + * The following fields in it shall be filled in by x->type->output:
> + *	payload_len

---
~Randy
