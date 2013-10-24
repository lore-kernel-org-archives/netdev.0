From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] net:sched  fix a bug about memery leak
Date: Thu, 24 Oct 2013 18:05:14 +0400
Message-ID: <5269291A.7050406@cogentembedded.com>
References: <1382605580-2629-1-git-send-email-windsdaemon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jing Wang <windsdaemon@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:44022 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754935Ab3JXOFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 10:05:16 -0400
Received: by mail-lb0-f176.google.com with SMTP id z5so1912202lbh.7
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 07:05:15 -0700 (PDT)
In-Reply-To: <1382605580-2629-1-git-send-email-windsdaemon@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 10/24/2013 01:06 PM, Jing Wang wrote:

> From: Jing Wang <windsdaemon@gmail.com>

> the code isn't properly release memory

> Signed-off-by: Jing Wang <windsdaemon@gmail.com>
> ---
>   net/sched/cls_route.c |    9 ++++++---
>   1 files changed, 6 insertions(+), 3 deletions(-)

> diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
> index 37da567..118f8d5 100644
> --- a/net/sched/cls_route.c
> +++ b/net/sched/cls_route.c
[...]
> @@ -517,6 +517,9 @@ reinsert:
>
>   errout:
>   	kfree(f);
> +errflt:
> +    kfree(head);

    Please indent with tab, not spaces.

WBR, Sergei
