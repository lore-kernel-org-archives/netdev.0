From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 1/6] bnxt: fix unsigned comparsion with 0
Date: Mon, 24 Jul 2017 10:48:17 -0700
Message-ID: <CACKFLikMZ_HUYPgnvU2bNQfLy86XVEgVWpkGRYry+HUb-Z_1ow@mail.gmail.com>
References: <20170724172523.13135-1-sthemmin@microsoft.com> <20170724172523.13135-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        David Miller <davem@davemloft.net>, pablo@netfilter.org,
        kadlec@blackhole.kfki.hu, fw@strlen.de,
        Netdev <netdev@vger.kernel.org>, linux-bluetooth@vger.kernel.org,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:33626 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754326AbdGXRsT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 13:48:19 -0400
Received: by mail-yw0-f171.google.com with SMTP id x125so53871531ywa.0
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 10:48:19 -0700 (PDT)
In-Reply-To: <20170724172523.13135-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 24, 2017 at 10:25 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Fixes warning because location is u32 and can never be netative
> warning: comparison of unsigned expression < 0 is always false [-Wtype-limits]
>
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>
