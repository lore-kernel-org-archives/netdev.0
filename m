From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 3/3] sh_eth: factor out sh_eth_emac_interrupt()
Date: Wed, 4 Jan 2017 15:13:54 +0300
Message-ID: <cab4c624-2225-beed-25f5-7bcf25b16e9b@cogentembedded.com>
References: <64514012.uUvlhX0YRQ@wasted.cogentembedded.com>
 <2316251.zKWDf5AMHG@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34056 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757289AbdADMOY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 07:14:24 -0500
Received: by mail-lf0-f50.google.com with SMTP id d16so11883396lfb.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 04:13:57 -0800 (PST)
In-Reply-To: <2316251.zKWDf5AMHG@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 03:11 PM, Sergei Shtylyov wrote:

> The E-MAC interrupt (EESR.ECI) is not always caused  by an error condition,
> so  it really shouldn't be handled by sh_eth_error(). Factor out the E-MAC
> interrupt handler, sh_eth_emac_interrupt(),  removing the ECI bit from the
> EESR's values throughout the driver...
>
> Update Cogent Embedded's copyright and clean up the whitespace in Renesas'
> copyright, while at it...
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

    Scrap it, I've just realized I never enable EESR.ECI...

MBR, Sergei
