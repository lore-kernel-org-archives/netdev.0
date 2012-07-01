From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH net-next 06/15] netfilter: Add NFPROTO_BUS hook constant
 for AF_BUS socket family
Date: Sun, 1 Jul 2012 04:15:52 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1207010411200.12387@frira.zrqbmnf.qr>
References: <1340988354-26981-1-git-send-email-vincent.sanders@collabora.co.uk> <1340988354-26981-7-git-send-email-vincent.sanders@collabora.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>
To: Vincent Sanders <vincent.sanders@collabora.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1340988354-26981-7-git-send-email-vincent.sanders@collabora.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 2012-06-29 18:45, Vincent Sanders wrote:

>AF_BUS sockets add a netfilter NF_HOOK() on the packet sending path.
>This allows packet to be mangled by registered netfilter hooks.

If you do touch netfiler, consider adding that mailing list as well.

>diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
>index c613cf0..0698924 100644
>--- a/include/linux/netfilter.h
>+++ b/include/linux/netfilter.h
>@@ -67,6 +67,7 @@ enum {
> 	NFPROTO_BRIDGE =  7,
> 	NFPROTO_IPV6   = 10,
> 	NFPROTO_DECNET = 12,
>+	NFPROTO_BUS,
> 	NFPROTO_NUMPROTO,
> };

Make use of the holes that were left.
