From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/4 net-next] net: bcmgenet: precalculate TxCB->bd_addr
Date: Tue, 09 Dec 2014 12:05:27 -0800
Message-ID: <54875607.7080002@gmail.com>
References: <20141204041150.A54952200C7@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34641 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaLIUFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 15:05:41 -0500
Received: by mail-pa0-f48.google.com with SMTP id rd3so1208538pab.35
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 12:05:41 -0800 (PST)
In-Reply-To: <20141204041150.A54952200C7@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/14 20:11, Petri Gynther wrote:
> There is 1-to-1 mapping between TxCBs and TxBDs. Precalculate TxCB->bd_addr
> once in bcmgenet_init_dma() instead of doing it over and over needlessly in
> bcmgenet_get_txcb().

Nice cleanup, thanks!

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> 
> Signed-off-by: Petri Gynther <pgynther@google.com>
> ---
--
Florian
