From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: use XPS if possible for
 bnx2x_select_queue instead of pure hash
Date: Sat, 01 Jun 2013 19:38:57 -0700 (PDT)
Message-ID: <20130601.193857.1132434060524891436.davem@davemloft.net>
References: <1370046775.24311.16.camel@edumazet-glaptop>
	<504C9EFCA2D0054393414C9CB605C37F20C955D6@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	govindarajulu90@gmail.com, hskinnemoen@google.com,
	eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab3FBCi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 22:38:58 -0400
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F20C955D6@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Sat, 1 Jun 2013 11:27:40 +0000

>> The bnx2x_select_queue() was using __skb_tx_hash() to select the
>> transmit queue, totally ignoring XPS settings, while XPS can help
>> performance quite significantly, so change the bnx2x_select_queue()
>> to use __dev_pick_tx() instead which will use XPS if configured.
>> 
>> Based on patches from Ying Cai and Havard Skinnemoen
>> 
>> Reported-by: govindarajulu.v <govindarajulu90@gmail.com>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Acked-by: Dmitry Kravkov <dmitry@broadcom.com>

Applied, thanks everyone.
