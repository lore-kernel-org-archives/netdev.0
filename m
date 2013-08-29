From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] tcp: TSO packets automatic sizing
Date: Thu, 29 Aug 2013 14:26:39 -0700
Message-ID: <1377811599.8277.43.camel@edumazet-glaptop>
References: <1377607592.8828.149.camel@edumazet-glaptop>
	 <20130829.155131.1753610025310087003.davem@davemloft.net>
	 <1377807977.8277.40.camel@edumazet-glaptop>
	 <20130829.163528.638691969523130618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	vanj@google.com, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f179.google.com ([209.85.213.179]:39960 "EHLO
	mail-ye0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756688Ab3H2V0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 17:26:43 -0400
Received: by mail-ye0-f179.google.com with SMTP id l10so244316yen.38
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 14:26:42 -0700 (PDT)
In-Reply-To: <20130829.163528.638691969523130618.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-29 at 16:35 -0400, David Miller wrote:

> 
> No objections from me.

We'll cook a different patch.

Idea is to feed tcp_set_rto() with the srtt found in the tcp metric
cache, and let tp->srtt value found in SYN/SYNACK (if available) as is.

(Be conservative for initial rto value, yet allow tp->srtt be the
current rtt on the network)

Thanks
