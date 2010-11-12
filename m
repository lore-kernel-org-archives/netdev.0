From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Prevent crashing when parsing bad X.25 facilities
Date: Fri, 12 Nov 2010 12:29:46 -0800 (PST)
Message-ID: <20101112.122946.102556009.davem@davemloft.net>
References: <1289570877.3090.274.camel@Dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew.hendry@gmail.com, netdev@vger.kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56518
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932420Ab0KLU3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:29:22 -0500
In-Reply-To: <1289570877.3090.274.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Fri, 12 Nov 2010 09:07:57 -0500

> @@ -149,9 +157,8 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
>  				break;
>  			default:
>  				printk(KERN_DEBUG "X.25: unknown facility %02X,"
> -					"length %d, values %02X, %02X, "
> -					"%02X, %02X\n",
> -					p[0], p[1], p[2], p[3], p[4], p[5]);
> +					"length %d\n"
> +					p[0], p[1]);
>  				break;

Thanks for not even compile testing your changes:

net/x25/x25_facilities.c: In function 'x25_parse_facilities':
net/x25/x25_facilities.c:161:6: error: expected ')' before 'p'
net/x25/x25_facilities.c:161:6: warning: too few arguments for format

I find this kind of carelessness extremely amusing coming from someone
who is so big on security theatre.

