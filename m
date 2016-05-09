From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v2 6/6] net sched: ife action fix late binding
Date: Sun, 8 May 2016 20:32:51 -0700
Message-ID: <CAM_iQpXfA47LoK-zNBk6QyucA4ogagTiWSbnd0x2CQs-28rw+w@mail.gmail.com>
References: <1462728392-28489-1-git-send-email-jhs@emojatatu.com> <1462728392-28489-7-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:33992 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbcEIDdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 23:33:11 -0400
Received: by mail-yw0-f175.google.com with SMTP id j74so239037324ywg.1
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 20:33:11 -0700 (PDT)
In-Reply-To: <1462728392-28489-7-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 8, 2016 at 10:26 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> @@ -689,7 +695,7 @@ static int tcf_ife_encode(struct sk_buff *skb, const struct tc_action *a,
>         /*
>            OUTERHDR:TOTMETALEN:{TLVHDR:Metadatum:TLVHDR..}:ORIGDATA
>            where ORIGDATA = original ethernet header ...
> -        */
> +       */

Irrelevant to the bug fix.
