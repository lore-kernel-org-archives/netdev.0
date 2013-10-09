From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: sh_eth: Fix RX packets errors on R8A7740
Date: Wed, 09 Oct 2013 22:27:50 +0200
Message-ID: <5255BC46.1060708@cogentembedded.com>
References: <1381127365-6521-1-git-send-email-nh-ky@jinso.co.jp> <20131008.160446.1960731810404939922.davem@davemloft.net> <20131009042454.GA16885@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, nh-ky@jinso.co.jp,
	netdev@vger.kernel.org, ryusuke.sakato.bx@renesas.com
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:41497 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688Ab3JIT3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 15:29:12 -0400
Received: by mail-we0-f177.google.com with SMTP id x55so1380322wes.22
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 12:29:11 -0700 (PDT)
In-Reply-To: <20131009042454.GA16885@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 09-10-2013 6:24, Simon Horman wrote:

>>> This patch will fix RX packets errors when receiving big size of data.
>>> Moreover, I set suitable parameters for get more stable when receiving
>>> packets.

>>> It was created on the top of mainline kernel v3.11.

>>> I tested this patch on Armadillo800eva, it appears to be working well.

>>> Would you please review and apply it for me.

>> Applied, but at some point someone has to add definitions for the
>> RMCR register fields so that this driver is not full of magic constants.

> Sergei, would it be possible for you to address this?

    Yes, perhaps, if I won't forget.

WBR, Sergei
