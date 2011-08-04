From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] mlx4: decreasing ref count when removing mac
Date: Thu, 4 Aug 2011 05:55:39 -0700
Message-ID: <CAL1RGDWVBWvc_p_XM2BQ-jV8DG19ZcbCcpntMJifED2frR+jcQ@mail.gmail.com>
References: <4E3A7CE8.4080407@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E3A7CE8.4080407-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> For older FW versions, when a Mac address removed from Mac table,
> we should set 0 for reference count for the corresponding Mac index.
> Fixes a bug where removing Mac from the table still left that entry as
> invalid.

This fixes my problems with MTU settings with old FW.

Tested-by: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
