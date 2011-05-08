From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipheth: Properly distinguish length and
 alignment in URBs and skbs
Date: Sun, 08 May 2011 15:46:22 -0700 (PDT)
Message-ID: <20110508.154622.35028516.davem@davemloft.net>
References: <20110503165751.GA6566@bart.evergreen.loc>
	<710D4D6CE160654C87478D18385BB9971BE3FDCA46@MDC-MAIL-CMS01.ubisoft.org>
	<1304444965.2873.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.hill@ubisoft.com, agimenez@sysvalve.es,
	linux-kernel@vger.kernel.org, dgiagio@gmail.com, dborca@yahoo.com,
	pmcenery@gmail.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304444965.2873.11.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 03 May 2011 18:49:25 +0100

> The USB protocol this driver implements appears to require 2 bytes of
> padding in front of each received packet.  This used to be equal to
> the value of NET_IP_ALIGN on x86, so the driver abused that constant
> and mostly worked, but this is no longer the case.  The driver also
> mixed up the URB and packet lengths, resulting in 2 bytes of junk at
> the end of the skb.
> 
> Introduce a private constant for the 2 bytes of padding; fix this
> confusion and check for the under-length case.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Compile-tested only, as I'm not cool enough for an iPhone either.
> This is applicable to net-next-2.6 or v2.6.38.

I've applied this to net-2.6 and will conditionally queue it up for
-stable, if we need further fixups we can add relative patches.

Thanks.
