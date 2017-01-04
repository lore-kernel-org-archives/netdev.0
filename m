From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] sh_eth: fix EESIPR values for SH77{34|63}
Date: Wed, 4 Jan 2017 22:27:02 +0300
Message-ID: <c2525f66-c5e7-0e2e-92de-d22d82d81920@cogentembedded.com>
References: <1819012.0ROIJmx7mp@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36700 "EHLO
        mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761809AbdADT1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 14:27:32 -0500
Received: by mail-lf0-f47.google.com with SMTP id x140so13682244lfa.3
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 11:27:07 -0800 (PST)
In-Reply-To: <1819012.0ROIJmx7mp@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 10:18 PM, Sergei Shtylyov wrote:

> As the SH77{34|63} manuals are freely available,  I've checked the EESIPR
> values written against the manuals, and they appeared to set the reserved
> bits 11-15 (which should be 0 on write). Fix those EESIPR values.
>
> Fixes: 380af9e390ec ("net: sh_eth: CPU dependency code collect to "struct sh_eth_cpu_data"")

    For SH7763 the bug is older than this commit but the code was common for 
all SH SoCs supported back then and so couldn't be fixed w/o affecting other 
SoCs. However, I suspect that the mask was incorrect even for the other SoCs...

> Fixes: f5d12767c8fd ("sh_eth: get SH77{34|63} support out of #ifdef")

    That's the point where SH7734/63 data were split...

> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

[...]

MBR, Sergei
