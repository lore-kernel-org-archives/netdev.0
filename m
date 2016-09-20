From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [RFC v2 06/12] qedr: Add support for QP verbs
Date: Tue, 20 Sep 2016 09:28:49 -0600
Message-ID: <20160920152849.GD32020@obsidianresearch.com>
References: <1474367764-9555-1-git-send-email-Ram.Amrani@cavium.com>
 <1474367764-9555-7-git-send-email-Ram.Amrani@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
        rajesh.borundia-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1474367764-9555-7-git-send-email-Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 20, 2016 at 01:35:58PM +0300, Ram Amrani wrote:
> +++ b/include/uapi/rdma/providers/qedr-abi.h
> @@ -43,4 +43,39 @@ struct qedr_create_cq_uresp {
>         u16 icid;
>  };

Ugh, each patch keeps adding to this?

> +struct qedr_create_qp_ureq {
> +       u32 qp_handle_hi;
> +       u32 qp_handle_lo;
> +
> +       /* SQ */
> +       /* user space virtual address of SQ buffer */
> +       u64 sq_addr;
> +
> +       /* length of SQ buffer */
> +       size_t sq_len;

Do not use size_t, that is just asking for 32/64 bit interop problems.

> +struct qedr_create_qp_uresp {
> +       u32 qp_id;
> +       int atomic_supported;

int again, etc. You get the idea.

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
