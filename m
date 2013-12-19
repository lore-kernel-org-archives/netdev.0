From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net: fec: fix potential use after free
Date: Thu, 19 Dec 2013 20:32:31 +0100
Message-ID: <20131219193231.GB14612@netboy>
References: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:63942 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751677Ab3LSTcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:32:46 -0500
Received: by mail-ea0-f174.google.com with SMTP id b10so637119eae.5
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 11:32:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1387479182.19078.369.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 10:53:02AM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> skb_tx_timestamp(skb) should be called _before_ TX completion
> has a chance to trigger, otherwise it is too late and we access
> freed memory.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Fixes: de5fb0a05348 ("net: fec: put tx to napi poll function to fix dead lock")

So the hw_lock spin lock was protecting against this issue?

Nice catch. How ever did you find this?

Acked-by: Richard Cochran <richardcochran@gmail.com>
