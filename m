From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH] bnxt_en: Fix a VXLAN vs GENEVE issue
Date: Mon, 21 Nov 2016 23:15:30 -0800
Message-ID: <CACKFLim17ZxiSrGe+TPR2pXDFrcNvZ=h-_xEbsJULiuVoOybbg@mail.gmail.com>
References: <20161122051440.9748-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Prashant Sreedharan <prashant.sreedharan@broadcom.com>,
        Netdev <netdev@vger.kernel.org>, kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f181.google.com ([209.85.217.181]:36560 "EHLO
        mail-ua0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbcKVHPb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2016 02:15:31 -0500
Received: by mail-ua0-f181.google.com with SMTP id b35so7425827uaa.3
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 23:15:31 -0800 (PST)
In-Reply-To: <20161122051440.9748-1-christophe.jaillet@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 21, 2016 at 9:14 PM, Christophe JAILLET
<christophe.jaillet@wanadoo.fr> wrote:
> Knowing that:
>   #define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_VXLAN        (0x1UL << 0)
>   #define TUNNEL_DST_PORT_FREE_REQ_TUNNEL_TYPE_GENEVE       (0x5UL << 0)
> and that 'bnxt_hwrm_tunnel_dst_port_alloc()' is only called with one of
> these 2 constants, the TUNNEL_DST_PORT_ALLOC_REQ_TUNNEL_TYPE_GENEVE can not
> trigger.
>
> Replace the bit test that overlap by an equality test, just as in
> 'bnxt_hwrm_tunnel_dst_port_free()' above.
>
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>

Thanks.

Acked-by: Michael Chan <michael.chan@broadcom.com>
