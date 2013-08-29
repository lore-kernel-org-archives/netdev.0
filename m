From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] xgmac: use bufsz not dma_buf_sz in rx_refill
Date: Fri, 30 Aug 2013 00:31:03 +0400
Message-ID: <521FAF87.7070605@cogentembedded.com>
References: <20130829201151.GJ8764@redacted.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rob.herring@calxeda.com, netdev@vger.kernel.org
To: Kyle McMartin <kyle@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:43053 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954Ab3H2UbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:31:09 -0400
Received: by mail-lb0-f174.google.com with SMTP id w6so1155138lbh.33
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 13:31:07 -0700 (PDT)
In-Reply-To: <20130829201151.GJ8764@redacted.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/30/2013 12:11 AM, Kyle McMartin wrote:

> Noticed while debugging another issue that DMA debug turned up, looks
> like commit ef468d23 missed a case when switching to bufsz instead of

    Please also specify that commit's summary line in parens.

> priv->dma_buf_sz? (tbf, the whole handling of DMA buffers seems slightly
> suspect since we're not tracking the size, but trusting the hardware
> between map and unmap...)

> Signed-off-by: Kyle McMartin <kyle@redhat.com>

WBR, Sergei
