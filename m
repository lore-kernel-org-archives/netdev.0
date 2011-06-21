From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] mv643xx_eth: fix race in trasmit path.
Date: Tue, 21 Jun 2011 16:00:45 -0700 (PDT)
Message-ID: <20110621.160045.1770529742447572859.davem@davemloft.net>
References: <cover.1308555865.git.richard.cochran@omicron.at>
	<cover.1308555865.git.richard.cochran@omicron.at>
	<25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, stable@kernel.org,
	buytenh@wantstofly.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903Ab1FUXAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 19:00:50 -0400
In-Reply-To: <25a379578b71bf01f3c77ac76a193d26554f9e0c.1308555865.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 20 Jun 2011 09:48:07 +0200

> Because the socket buffer is freed in the completion interrupt, it is not
> safe to access it after submitting it to the hardware.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Since this isn't actually a bonafide bug fix I've applied this to net-next-2.6
