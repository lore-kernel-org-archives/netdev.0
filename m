From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH kernel 4/4] sh_eth: Fix DMA-API usage for RX buffers
Date: Fri, 27 Feb 2015 23:36:59 +0300
Message-ID: <54F0D56B.8000809@cogentembedded.com>
References: <1422319232.3524.14.camel@xylophone.i.decadent.org.uk> <1422319824.3524.24.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	"David S.Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:42272 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888AbbB0UhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:37:05 -0500
Received: by lbiw7 with SMTP id w7so19524549lbi.9
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 12:37:04 -0800 (PST)
In-Reply-To: <1422319824.3524.24.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/27/2015 03:50 AM, Ben Hutchings wrote:

> - Use the return value of dma_map_single(), rather than calling
>    virt_to_page() separately
> - Check for mapping failue
> - Call dma_unmap_single() rather than dma_sync_single_for_cpu()

> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>

    I wonder whether you're aware at the previous Renesas' attemept at fixing 
DMA issues:

http://marc.info/?t=141586251000003

    It was turned down because they tried to deal with several issues in one 
patch, and they have failed to follow up. Could you look at the rest of the 
DMA issues reported (and not reported) in that patch?

[...]

WBR, Sergei
