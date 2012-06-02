From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] fec_mpc52xx: fix timestamp filtering
Date: Sat, 02 Jun 2012 17:09:28 -0400 (EDT)
Message-ID: <20120602.170928.2285518051173826178.davem@davemloft.net>
References: <1338642246-10911-1-git-send-email-stephan@gatzka.org>
	<20120602190605.GA2202@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephan@gatzka.org, netdev@vger.kernel.org, stable@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965421Ab2FBVJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 17:09:29 -0400
In-Reply-To: <20120602190605.GA2202@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sat, 2 Jun 2012 21:06:05 +0200

> On Sat, Jun 02, 2012 at 03:04:06PM +0200, Stephan Gatzka wrote:
>> skb_defer_rx_timestamp was called with a freshly allocated skb but must
>> be called with rskb instead.
> 
> Thanks for checking this, and sorry for the trouble it caused you.
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Applied.
