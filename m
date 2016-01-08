From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net: pktgen: support injecting packets for qdisc testing
Date: Thu, 07 Jan 2016 18:28:50 -0800
Message-ID: <568F1EE2.7020107@gmail.com>
References: <20160108020908.5940.89612.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35656 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473AbcAHC3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 21:29:00 -0500
Received: by mail-pa0-f41.google.com with SMTP id ho8so12814294pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 18:29:00 -0800 (PST)
In-Reply-To: <20160108020908.5940.89612.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-01-07 06:09 PM, John Fastabend wrote:
> Add another xmit_mode to pktgen to allow testing xmit functionality
> of qdiscs. The new mode "queue_xmit" injects packets at
> __dev_queue_xmit() so that qdisc is called.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  Documentation/networking/pktgen.txt |    2 +-
>  net/core/pktgen.c                   |   43 +++++++++++++++++++++++++++++++++++
>  2 files changed, 44 insertions(+), 1 deletion(-)
> 

Hi Jamal,

per your comment about using pktgen to test qdiscs here is the
patch I've been using most the day which has been working well.
I'm guessing this is more or less what you had in mind.

Thanks,
John
