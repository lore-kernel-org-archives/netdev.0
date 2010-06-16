From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [PATCH 3/3] cxgb4i_v4.3 : main driver files
Date: Wed, 16 Jun 2010 17:19:02 -0500
Message-ID: <4C194DD6.7090706@cs.wisc.edu>
References: <1275973167-8640-1-git-send-email-rakesh@chelsio.com> <1275973167-8640-2-git-send-email-rakesh@chelsio.com> <1275973167-8640-3-git-send-email-rakesh@chelsio.com> <1275973167-8640-4-git-send-email-rakesh@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, LK-NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LK-SCSIDev <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Bottomley <James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>,
        Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncCLPJla3WGRDQmuXgBBoEwSSDEg-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1275973167-8640-4-git-send-email-rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>,
	<mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 06/07/2010 11:59 PM, Rakesh Ranjan wrote:
> From: Rakesh Ranjan<rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
>
>
> Signed-off-by: Rakesh Ranjan<rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> ---
>   drivers/scsi/cxgbi/cxgb4i.h         |  175 +++++
>   drivers/scsi/cxgbi/cxgb4i_ddp.c     |  653 ++++++++++++++++
>   drivers/scsi/cxgbi/cxgb4i_init.c    |  317 ++++++++
>   drivers/scsi/cxgbi/cxgb4i_offload.c | 1409 +++++++++++++++++++++++++++++++++++
>   4 files changed, 2554 insertions(+), 0 deletions(-)
>   create mode 100644 drivers/scsi/cxgbi/cxgb4i.h
>   create mode 100644 drivers/scsi/cxgbi/cxgb4i_ddp.c
>   create mode 100644 drivers/scsi/cxgbi/cxgb4i_init.c
>   create mode 100644 drivers/scsi/cxgbi/cxgb4i_offload.c
>

Do you think you can look through this patch and identify the places 
where you basically just copied a cxgb3i function or copied it but 
renamed some stuff and then move these type of things to the lib patch?

A lot of the scatter list stuff for example looks the same in each driver.

ddp_find_unused_entries - cxgb4i_ddp_find_unused_entries
ddp_unmark_entries - cxgb4i_ddp_unmark_entries
cxgb3i_ddp_find_page_index - cxgb4i_ddp_find_page_index
cxgb3i_ddp_adjust_page_table - cxgb4i_ddp_adjust_page_table
..... (lots of the ddp code looks duplicated).

The *_offload.c code looks the same.

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
