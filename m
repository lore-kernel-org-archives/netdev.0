From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mlx5/core: Use memdup_user() rather than duplicating
 its implementation
Date: Mon, 22 Aug 2016 17:05:51 -0700 (PDT)
Message-ID: <20160822.170551.1169143382468496713.davem@davemloft.net>
References: <566ABCD9.1060404@users.sourceforge.net>
        <ceb39933-438d-920d-f294-ea0ce32fd171@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        julia.lawall-L2FTfq7BK8M@public.gmane.org
To: elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ceb39933-438d-920d-f294-ea0ce32fd171-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Date: Sat, 20 Aug 2016 08:01:22 +0200

> From: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> Date: Sat, 20 Aug 2016 07:50:09 +0200
> 
> * Reuse existing functionality from memdup_user() instead of keeping
>   duplicate source code.
> 
>   This issue was detected by using the Coccinelle software.
> 
> * Return directly if this copy operation failed.
> 
> Signed-off-by: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
