From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] mlx4: Fixing Ethernet unicast packet steering
Date: Wed, 3 Aug 2011 19:53:40 -0700
Message-ID: <CAL1RGDXkbWjC1W0AcjXo6jm9bh1mtnx8nStCZL+ty4ywcCQ0yw@mail.gmail.com>
References: <4E395A18.8070600@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E395A18.8070600-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Yevgeny!

Actually on further testing it seems that things are still not perfect
with my old firmware at least.

If I do "ifconfig eth6 mtu 1450" (where eth6 is a mlx4_en interface)
then I am no longer able to get traffic through the interface; if I
have a ping running it stops immediately.  It seems any mtu change
triggers this (increasing the mtu above the default has the same
effect, and restoring the mtu to the default doesn't fix it).

Haven't tried to debug further.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
