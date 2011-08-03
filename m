From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH] mlx4: Fixing Ethernet unicast packet steering
Date: Wed, 3 Aug 2011 12:06:56 -0700
Message-ID: <CAL1RGDVHnd2x2pWgaYG2vKKJk-qYfQp3T5pgJ-48HeaMA=9_EA@mail.gmail.com>
References: <4E39594C.4090808@mellanox.co.il> <CAL1RGDU+=wX40J_uktWxMiHNx5Sed-d3b2J4_4JTg=tyqbKsEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDU+=wX40J_uktWxMiHNx5Sed-d3b2J4_4JTg=tyqbKsEg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 3, 2011 at 11:58 AM, Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org> wrote:
>> For older FW versions, fixing the usage of per port Mac table.
>> For each port we must define the base QP number, which is passed
>> to the HW.
>> Setting the correct value in SET_PORT FW command to enable the steering.

> Thanks, testing this now.

Yep, works well on my backrev FW boards.  Dave, you want to merge this
or should I?

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
