From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v4 net-next 0/4] act_mirred: Ingress actions support
Date: Thu, 13 Oct 2016 21:24:25 -0700
Message-ID: <CAM_iQpVBYwfdtit3s-ZP7YWuX9FrqHoTKnUcu8pvJhoAABXEzw@mail.gmail.com>
References: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Eric Dumazet <edumazet@google.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35968 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbcJNEYq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 00:24:46 -0400
Received: by mail-it0-f67.google.com with SMTP id o19so111166ito.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 21:24:46 -0700 (PDT)
In-Reply-To: <1476338804-25440-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2016 at 11:06 PM, Shmulik Ladkani
<shmulik.ladkani@gmail.com> wrote:
> This patch series implements action mirred 'ingress' actions
> TCA_INGRESS_REDIR and TCA_INGRESS_MIRROR.
>
> This allows attaching filters whose target is to hand matching skbs into
> the rx processing of a specified device.
>
> v4:
>   in 4/4, check ret code of netif_receive_skb, as suggested by Cong Wang
> v3:
>   in 4/4, addressed non coherency due to reading m->tcfm_eaction multiple
>   times, as spotted by Eric Dumazet
> v2:
>   in 1/4, declare tcfm_mac_header_xmit as bool instead of int
>

For the whole series,

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>


Thanks for your update!
