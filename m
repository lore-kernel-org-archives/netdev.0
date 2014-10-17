From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v2] vxlan: remove the dead codes
Date: Fri, 17 Oct 2014 10:33:08 -0700
Message-ID: <CAHA+R7O7Yyd2XMkMnv5b_TLFekPCRRtOGG7bHgHs2Qd+YRu3Hg@mail.gmail.com>
References: <1413525844-2406-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:52921 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638AbaJQRdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 13:33:09 -0400
Received: by mail-qg0-f42.google.com with SMTP id z60so894019qgd.1
        for <netdev@vger.kernel.org>; Fri, 17 Oct 2014 10:33:08 -0700 (PDT)
In-Reply-To: <1413525844-2406-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 16, 2014 at 11:04 PM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> remove the dead codes, no user uses vxlan_salt
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  drivers/net/vxlan.c |    4 ----
>  1 file changed, 4 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 77ab844..855a81d 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -152,8 +152,6 @@ struct vxlan_dev {
>         struct hlist_head fdb_head[FDB_HASH_SIZE];
>  };
>
> -/* salt for hash table */
> -static u32 vxlan_salt __read_mostly;

Hmm, it has never been used since it was born. Maybe we should
really use for vxlan hash table?
