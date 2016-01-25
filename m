From: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>
Subject: Re: [dm-devel] [PATCH 22/26] iscsi_tcp: Use ahash
Date: Mon, 25 Jan 2016 13:50:06 -0600
Message-ID: <56A67C6E.1090903@cs.wisc.edu>
References: <20160124131021.GA31153@gondor.apana.org.au> <E1aNKZy-0008Fl-01@gondolin.me.apana.org.au>
Reply-To: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: device-mapper development <dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Linux Crypto Mailing List <linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cifs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ecryptfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-f2fs-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        keyrings-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ceph-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-afs-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, drbd-dev-cunTk1MwBs8qoQakbn7OcQ@public.gmane.org,
        open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Return-path: <open-iscsi+bncBCZ4TFNN2YMRB57YTG2QKGQEKPU7ICY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <E1aNKZy-0008Fl-01-XQvu0L+U/CjiRBuR/1fSEKKkPtS2pBon@public.gmane.org>
List-Post: <https://groups.google.com/group/open-iscsi/post>, <mailto:open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:open-iscsi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/open-iscsi
Sender: open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <https://groups.google.com/group/open-iscsi/subscribe>, <mailto:open-iscsi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+856124926423+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/open-iscsi/subscribe>
List-Id: netdev.vger.kernel.org

On 01/24/2016 07:19 AM, Herbert Xu wrote:
> This patch replaces uses of the long obsolete hash interface with
> ahash.
> 
> Signed-off-by: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
> ---
> 
>  drivers/scsi/iscsi_tcp.c    |   54 ++++++++++++++++++++++++++------------------
>  drivers/scsi/iscsi_tcp.h    |    4 +--
>  drivers/scsi/libiscsi_tcp.c |   29 +++++++++++++----------
>  include/scsi/libiscsi_tcp.h |   13 +++++-----
>  4 files changed, 58 insertions(+), 42 deletions(-)
> 

iSCSI parts look ok.

Reviewed-by: Mike Christie <michaelc-hcNo3dDEHLuVc3sceRu5cw@public.gmane.org>

-- 
You received this message because you are subscribed to the Google Groups "open-iscsi" group.
To unsubscribe from this group and stop receiving emails from it, send an email to open-iscsi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
To post to this group, send email to open-iscsi-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
Visit this group at https://groups.google.com/group/open-iscsi.
For more options, visit https://groups.google.com/d/optout.
