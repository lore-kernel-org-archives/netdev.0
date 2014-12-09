From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 4/4 net-next] net: bcmgenet: rename bcmgenet_hw_params->bds_cnt
 and GENET_DEFAULT_BD_CNT
Date: Tue, 09 Dec 2014 12:05:56 -0800
Message-ID: <54875624.2070502@gmail.com>
References: <20141204041200.8AB8A2200C7@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Petri Gynther <pgynther@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:48997 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbaLIUGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 15:06:11 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so1223015pab.6
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 12:06:10 -0800 (PST)
In-Reply-To: <20141204041200.8AB8A2200C7@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/12/14 20:12, Petri Gynther wrote:
> bcmgenet_hw_params->bds_cnt and GENET_DEFAULT_BD_CNT are used only in Tx init.
> Rename them accordingly:
> - bcmgenet_hw_params->bds_cnt => bcmgenet_hw_params->tx_bds_per_q
> - GENET_DEFAULT_BD_CNT => GENET_Q16_TX_BD_CNT
> 
> Signed-off-by: Petri Gynther <pgynther@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

--
Florian
