From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 3/6] new pcmcia IDs for hostap
Date: Wed, 17 May 2006 18:03:36 -0400
Message-ID: <1147903416.31641.11.camel@dv>
References: <200605161621.22459.linux-arm@hrw.one.pl>
	 <200605161724.53495.linux-arm@hrw.one.pl> <1147814144.14914.38.camel@dv>
	 <200605171036.05164.linux-arm@hrw.one.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jouni Malinen <jkmaline@cc.hut.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:45235 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1751186AbWEQWDu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 18:03:50 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FgU7R-0002ok-Rv
	for netdev@vger.kernel.org; Wed, 17 May 2006 18:03:49 -0400
To: Marcin Juszkiewicz <linux-arm@hrw.one.pl>
In-Reply-To: <200605171036.05164.linux-arm@hrw.one.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-17 at 10:36 +0200, Marcin Juszkiewicz wrote:
> That one I sent to You, lkml over month ago but you had it already in 
> 24-hostap_cs_id.diff patch (which you told later to ignore).

Sorry, I was swamped with other things and didn't have time to recheck
all entries.

> Signed-off-by: Marcin Juszkiewicz <openembedded@hrw.one.pl>
Signed-off-by: Pavel Roskin <proski@gnu.org>

>  drivers/net/wireless/hostap/hostap_cs.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> Index: linux/drivers/net/wireless/hostap/hostap_cs.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/hostap/hostap_cs.c	2006-05-17 10:23:00.000000000 +0200
> +++ linux/drivers/net/wireless/hostap/hostap_cs.c	2006-05-17 10:25:45.000000000 +0200
> @@ -923,6 +923,12 @@
>  	PCMCIA_DEVICE_PROD_ID12(
>  		"ZoomAir 11Mbps High", "Rate wireless Networking",
>  		0x273fe3db, 0x32a1eaee),
> +	PCMCIA_DEVICE_PROD_ID123(
> +		"Pretec", "CompactWLAN Card 802.11b", "2.5",
> +		0x1cadd3e5, 0xe697636c, 0x7a5bfcf1),
> +	PCMCIA_DEVICE_PROD_ID123(
> +		"U.S. Robotics", "IEEE 802.11b PC-CARD", "Version 01.02",
> +		0xc7b8df9d, 0x1700d087, 0x4b74baa0),
>  	PCMCIA_DEVICE_NULL
>  };
>  MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);
> 
> 
-- 
Regards,
Pavel Roskin

