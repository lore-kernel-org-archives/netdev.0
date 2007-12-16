From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4]: Make tcp_input_metrics() get minimum RTO via
 tcp_rto_min()
Date: Sun, 16 Dec 2007 14:00:39 -0800 (PST)
Message-ID: <20071216.140039.115193929.davem@davemloft.net>
References: <d72b7ace0712141844x6392ceb6y5cb39d9a81f950e6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: satoru.satoh@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762012AbXLPWAy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 17:00:54 -0500
In-Reply-To: <d72b7ace0712141844x6392ceb6y5cb39d9a81f950e6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Satoru SATOH" <satoru.satoh@gmail.com>
Date: Sat, 15 Dec 2007 11:44:46 +0900

> tcp_input_metrics() refers to the built-time constant TCP_RTO_MIN
> regardless of configured minimum RTO with iproute2.
> 
> The following fixes that.
> 
> 
> Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

Thanks for this bug fix, patch applied.
