From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v4 net-next 1/4] net/sched: act_mirred: Rename
 tcfm_ok_push to tcfm_mac_header_xmit and make it a bool
Date: Thu, 13 Oct 2016 07:55:58 -0400
Message-ID: <e06d193e-6512-9301-9f56-c1bb5c98ca1f@mojatatu.com>
References: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
 <1476338804-25440-2-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35007 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754509AbcJML4A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 07:56:00 -0400
Received: by mail-io0-f193.google.com with SMTP id p26so4771676ioo.2
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 04:56:00 -0700 (PDT)
In-Reply-To: <1476338804-25440-2-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-10-13 02:06 AM, Shmulik Ladkani wrote:
> 'tcfm_ok_push' specifies whether a mac_len sized push is needed upon
> egress to the target device (if action is performed at ingress).
>
> Rename it to 'tcfm_mac_header_xmit' as this is actually an attribute of
> the target device (and use a bool instead of int).
>
> This allows to decouple the attribute from the action to be taken.
>
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
