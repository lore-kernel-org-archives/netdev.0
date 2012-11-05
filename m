From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 6/6] net: calxedaxgmac: ip align receive buffers
Date: Mon, 05 Nov 2012 08:53:37 -0800
Message-ID: <1352134417.2747.0.camel@edumazet-glaptop>
References: <1352132544-15809-1-git-send-email-robherring2@gmail.com>
	 <1352132544-15809-7-git-send-email-robherring2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Rob Herring <rob.herring@calxeda.com>
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:59104 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019Ab2KEQxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 11:53:49 -0500
Received: by mail-pa0-f46.google.com with SMTP id hz1so4059082pad.19
        for <netdev@vger.kernel.org>; Mon, 05 Nov 2012 08:53:48 -0800 (PST)
In-Reply-To: <1352132544-15809-7-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-05 at 10:22 -0600, Rob Herring wrote:
> From: Rob Herring <rob.herring@calxeda.com>
> 
> On gcc 4.7, we will get alignment traps in the ip stack if we don't align
> the ip headers on receive. The h/w can support this, so use ip aligned
> allocations.
> 
> Cut down the unnecessary padding on the allocation. The buffer can start on
> any byte alignment, but the size including the begining offset must be 8
> byte aligned. So the h/w buffer size must include the NET_IP_ALIGN offset.
> 
> Thanks to Eric Dumazet for the initial patch highlighting the padding issues.
> 
> Signed-off-by: Rob Herring <rob.herring@calxeda.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
