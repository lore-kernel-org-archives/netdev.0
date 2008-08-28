From: Karen Xie <kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/4 2.6.28] cxgb3i iscsi initiator driver
Date: Wed, 27 Aug 2008 21:21:56 -0700
Message-ID: <200808280421.m7S4LuUp006452@localhost.localdomain>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Cc: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, daisyc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, wenxiong-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, bhua-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <grbounce-FC1hwAUAAAA0O9VQcsxVj1UPjHD9r3x_=glio-open-iscsi=m.gmane.org-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Post: <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://googlegroups.com/group/open-iscsi/subscribe>,
	<mailto:open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


Hi, everyone,

Please review our new version of the iSCSI Initiator drivers for Chelsio S3 adapters. We have updated the code with the feedbacks received, including getting rid of most of the __GFP_NOFAIL allocation.

The cxgb3i driver provides iscsi acceleration (PDU digest offload and payload direct-placement) to the open-iscsi initiator. It accesses the hardware through the cxgb3 module.

The accelerated iscsi traffic uses a private IP address which is unknown to the OS.

netdev list, please review part 1, 2 and cxgb3i_offload.[ch] in part 4 which handle the iscsi connection APIs to the adapter.

Thanks.
Karen
