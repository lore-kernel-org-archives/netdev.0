From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] tulip VLAN support
Date: Wed, 05 Jan 2005 17:12:57 -0500
Message-ID: <41DC6669.9090407@pobox.com>
References: <20050105193425.GY18847@sventech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Johannes Erdfelt <johannes@erdfelt.com>
In-Reply-To: <20050105193425.GY18847@sventech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Johannes Erdfelt wrote:
> @@ -259,7 +259,7 @@
>  #define RX_RING_SIZE	128 
>  #define MEDIA_MASK     31
>  
> -#define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer. */
> +#define PKT_BUF_SZ		1540	/* Size of each temporary Rx buffer. */


This is the reason why the tulip "vlan" patch is continually rejected. 
You shouldn't need to increase this constant, but rather follow the 
other "large MTU" driver conversions.

Donald Becker's tulip.c (on which the kernel tulip is based) supports 
proper MTU changing: ftp://ftp.scyld.com/pub/network/

	Jeff
