From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: Consolidate clock handling
Date: Thu, 12 Oct 2017 22:31:08 +0300
Message-ID: <27fba919-6705-dc9b-f164-f38ed1545a64@cogentembedded.com>
References: <1507796693-14268-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        "David S . Miller" <davem@davemloft.net>,
        Simon Horman <horms+renesas@verge.net.au>,
        =?UTF-8?Q?Niklas_S=c3=b6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f46.google.com ([209.85.215.46]:46693 "EHLO
        mail-lf0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751900AbdJLTbM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 15:31:12 -0400
Received: by mail-lf0-f46.google.com with SMTP id g70so7107455lfl.3
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 12:31:11 -0700 (PDT)
In-Reply-To: <1507796693-14268-1-git-send-email-geert+renesas@glider.be>
Content-Language: en-MW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 10/12/2017 11:24 AM, Geert Uytterhoeven wrote:

> The module clock is used for two purposes:
>    - Wake-on-LAN (WoL), which is optional,
>    - gPTP Timer Increment (GTI) configuration, which is mandatory.
> 
> As the clock is needed for GTI configuration anyway, WoL is always
> available.  Hence remove duplication and repeated obtaining of the clock
> by making GTI use the stored clock for WoL use.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
