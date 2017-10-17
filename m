From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 2/3] net: sh_eth: rename name structures as
 rcar_gen[12]_*
Date: Tue, 17 Oct 2017 13:17:54 +0300
Message-ID: <efe31736-9dda-ae2c-98c1-39073c64fdc7@cogentembedded.com>
References: <20171017074747.24159-1-horms+renesas@verge.net.au>
 <20171017074747.24159-3-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:52879 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760797AbdJQKR4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 06:17:56 -0400
Received: by mail-lf0-f43.google.com with SMTP id b190so1366864lfg.9
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 03:17:55 -0700 (PDT)
In-Reply-To: <20171017074747.24159-3-horms+renesas@verge.net.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 10/17/2017 10:47 AM, Simon Horman wrote:

> Rename structures describing R-Car SoCs as rcar_gen[12]_*
> rather than r8a77[79]x_*. This seems a little easier on the
> eyes will make things slightly cleaner in a follow-up
       ^
    "And" missing here?

> patch that adds fallback-compatibility strings for these SoCs.
> 
> Note that R-Car Gen2 and RZ/G1 have many compatible IP blocks.  The
> approach that has been consistently taken for other IP blocks is to name
> common code, compatibility strings and so on after Rcar Gen2.

    R-Car.

> Also rename sh_eth_set_rate_r8a777x as sh_eth_set_rate_rcar as
> it it is used by the R-Car generations supported by the driver.
> 
> This patch should have no run-time effect and
> is compile-tested only.
> 
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

[...]

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
