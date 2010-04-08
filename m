From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [PATCH 3/3] cxgb4i: iscsi and pdu processing part
Date: Thu, 08 Apr 2010 14:15:50 -0500
Message-ID: <4BBE2B66.8090900@cs.wisc.edu>
References: <1270728855-20951-1-git-send-email-rakesh@chelsio.com> <1270728855-20951-2-git-send-email-rakesh@chelsio.com> <1270728855-20951-3-git-send-email-rakesh@chelsio.com> <1270728855-20951-4-git-send-email-rakesh@chelsio.com>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Rakesh Ranjan <rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        James.Bottomley-JuX6DAaQMKPCXq6kfMZ53/egYHeGw8Jk@public.gmane.org
To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <3eCu-SwgLCq0ZVPUNRYPPf.jVfP.RQhbcRa-VfPfVTbbTYRTebhcf.PbZ-WNnxsJb2WYALHLMFiseIBxPsWskHk0ljAL8bYrjMMd8@public.gmane.org>
In-Reply-To: <1270728855-20951-4-git-send-email-rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
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

On 04/08/2010 07:14 AM, Rakesh Ranjan wrote:
> From: Rakesh Ranjan<rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
>
>
> Signed-off-by: Rakesh Ranjan<rakesh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
> ---
>   drivers/scsi/cxgb4i/cxgb4i_iscsi.c |  715 ++++++++++++++++++++++++++++++++++++
>   drivers/scsi/cxgb4i/cxgb4i_pdu.c   |  475 ++++++++++++++++++++++++
>   drivers/scsi/cxgb4i/cxgb4i_pdu.h   |   61 +++
>   3 files changed, 1251 insertions(+), 0 deletions(-)
>   create mode 100644 drivers/scsi/cxgb4i/cxgb4i_iscsi.c
>   create mode 100644 drivers/scsi/cxgb4i/cxgb4i_pdu.c
>   create mode 100644 drivers/scsi/cxgb4i/cxgb4i_pdu.h
>

The code in these files looks like the code is the cxgb3i iscsi and pdu 
code. Can you just make a common cxgb3i iscsi/pdu layer and add some 
callouts?

Something similar to what qla2xxx or lpfc has done to support multiple 
cards. In their case they have common fc and driver stuff and then 
callouts for hw specifics?

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To unsubscribe from this group, send email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit this group at http://groups.google.com/group/open-iscsi?hl=en.
