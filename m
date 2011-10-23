From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: [PATCH 05/10] RDMA/cxgb4: Add DB Overflow Avoidance.
Date: Sun, 23 Oct 2011 10:33:49 -0500
Message-ID: <4EA433DD.6090805@opengridcomputing.com>
References: <1319044264-779-1-git-send-email-vipul@chelsio.com> <1319044264-779-6-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1319044264-779-6-git-send-email-vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 10/19/2011 12:10 PM, Vipul Pandya wrote:
>          - get FULL/EMPTY/DROP events from LLD
>
>          - on FULL event, disable normal user mode DB rings.
>
>          - add modify_qp semantics to allow user processes to call into
>          the kernel to ring doobells without overflowing.
>
>          Add DB Full/Empty/Drop stats.
>
>          Mark queues when created indicating the doorbell state.
>
>          If we're in the middle of db overflow avoidance, then newly created
>          queues should start out in this mode.
>

Hey Vipul,

I just realized, we need to bump the ABI for iw_cxgb4 with this series 
so the user mode library can know if the driver supports the kernel mode 
db ringing. So bump C4IW_UVERBS_ABI_VERSION to 3.

Steve.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
