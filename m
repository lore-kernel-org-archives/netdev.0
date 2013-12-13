From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next v2 2/6] net_sched: act: use standard struct list_head
Date: Fri, 13 Dec 2013 14:32:18 +0800
Message-ID: <CABa6K_H_f_9sS4pH2gE2YD_KUHOVMGRwpy1x8Q-i3mFDEmQXjA@mail.gmail.com>
References: <1386910604-1870-1-git-send-email-xiyou.wangcong@gmail.com> <1386910604-1870-3-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:56382 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891Ab3LMGci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 01:32:38 -0500
Received: by mail-ie0-f175.google.com with SMTP id x13so2261351ief.34
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 22:32:38 -0800 (PST)
In-Reply-To: <1386910604-1870-3-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 13, 2013 at 12:56 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
> @@ -85,12 +86,18 @@ static inline int
>  tcf_exts_is_predicative(struct tcf_exts *exts)
>  {
>  #ifdef CONFIG_NET_CLS_ACT
> -       return !!exts->action;
> +       return list_empty(&exts->head);
>  #else
>         return 0;
>  #endif
>  }
>

You missed a "!".

Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
