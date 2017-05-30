From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 6/7] bnxt_en: Implement xmit_more.
Date: Mon, 29 May 2017 20:49:19 -0700
Message-ID: <CACKFLikMBfxxmF3tTk_BkyHvb+FJzcsBqOnBQDtfWfZ5qZLT6A@mail.gmail.com>
References: <1496099170-701-1-git-send-email-michael.chan@broadcom.com>
 <1496099170-701-7-git-send-email-michael.chan@broadcom.com> <BLUPR0701MB20040DED85E53FEFE75C591E8DF00@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:35616 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750821AbdE3DtV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 23:49:21 -0400
Received: by mail-lf0-f52.google.com with SMTP id a5so42213085lfh.2
        for <netdev@vger.kernel.org>; Mon, 29 May 2017 20:49:20 -0700 (PDT)
In-Reply-To: <BLUPR0701MB20040DED85E53FEFE75C591E8DF00@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 29, 2017 at 8:28 PM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>
>> -       bnxt_db_write(bp, txr->tx_doorbell, DB_KEY_TX | prod);
>> +       if (!skb->xmit_more)
>> +               bnxt_db_write(bp, txr->tx_doorbell, DB_KEY_TX | prod);
>
> DQL can prevent you from getting the xmit_more marked SKB,
> so you should probably also check for netif_xmit_stopped().

Good point.  Thanks.
