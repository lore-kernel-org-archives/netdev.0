From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [PATCH v5 0/3] cxgbi iscsi driver
Date: Thu, 19 Aug 2010 17:43:16 -0500
Message-ID: <4C6DB384.6020009@cs.wisc.edu>
References: <201008170355.o7H3trvW020987@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, rranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
        James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <open-iscsi+bncCLPJla3WGRD15LbjBBoEg_ofOQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <201008170355.o7H3trvW020987-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Post: <http://groups.google.com/group/open-iscsi/post?hl=en_US>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/?hl=en_US>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/open-iscsi?hl=en_US>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/open-iscsi/subscribe?hl=en_US>,
 <mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 08/16/2010 10:55 PM, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org wrote:
> [PATCH v5 0/3] cxgbi iscsi driver
>
> From: Karen Xie<kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
>
> This patchset includes:
>
> 1. added libcxgbi as the common library for both cxgb4i and cxgb3i driver
> 2. added cxgb4i iscsi initiator v5.
> 3. changed cxgb3i to use libcxgbi.
>
> Version 5 changes:
> - got rid of log_error/warn/info and used pr_<level>  instead.
> - "%zu" for printing out sizeof().
> - made sure all printk messages have trailing "."
>

iSCSI and scsi parts look ok to me.

Reviewed-by: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>

I looked at the network code and it looks similar to what is in the 
cxgb3i driver upstream, so I think it should be ok, but I am not 100% 
sure so probably needs a netdev ack.

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
