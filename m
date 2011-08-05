From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mlx4: decreasing ref count when removing mac
Date: Fri, 05 Aug 2011 03:36:21 -0700 (PDT)
Message-ID: <20110805.033621.638948788704368568.davem@davemloft.net>
References: <4E3A7CE8.4080407@mellanox.co.il>
	<CAL1RGDWVBWvc_p_XM2BQ-jV8DG19ZcbCcpntMJifED2frR+jcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDWVBWvc_p_XM2BQ-jV8DG19ZcbCcpntMJifED2frR+jcQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Thu, 4 Aug 2011 05:55:39 -0700

>> For older FW versions, when a Mac address removed from Mac table,
>> we should set 0 for reference count for the corresponding Mac index.
>> Fixes a bug where removing Mac from the table still left that entry as
>> invalid.
> 
> This fixes my problems with MTU settings with old FW.
> 
> Tested-by: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>

Applied, thanks everyone.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
