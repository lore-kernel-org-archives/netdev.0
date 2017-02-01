From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: fix wakeup event reporting from MagicPacket
Date: Wed, 1 Feb 2017 18:56:10 +0300
Message-ID: <75b5c064-21e6-0fd6-d335-afafff412f2e@cogentembedded.com>
References: <20170201144155.17123-1-niklas.soderlund+renesas@ragnatech.se>
 <20170201144155.17123-3-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34085 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750945AbdBAP4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 10:56:14 -0500
Received: by mail-lf0-f43.google.com with SMTP id v186so230866623lfa.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 07:56:13 -0800 (PST)
In-Reply-To: <20170201144155.17123-3-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/01/2017 05:41 PM, Niklas Söderlund wrote:

> If a link change interrupt happens along side the MagicPacket interrupt
> and the link change interrupt is ignored the interrupt handler will
> return and the wakeup event is not register. Fix this by moving the
> MagicPacket check before the link change check.
>
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

[...]

MBR, Sergei
