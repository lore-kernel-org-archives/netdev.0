From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: no need to test for the return type of
 of_property_read_u32
Date: Tue, 24 Nov 2015 16:09:58 -0500 (EST)
Message-ID: <20151124.160958.1830413240893006576.davem@davemloft.net>
References: <1448286708-4698-1-git-send-email-saurabh.truth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: B38611@freescale.com, fabio.estevam@freescale.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: saurabh.truth@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753961AbbKXVKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 16:10:04 -0500
In-Reply-To: <1448286708-4698-1-git-send-email-saurabh.truth@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saurabh Sengar <saurabh.truth@gmail.com>
Date: Mon, 23 Nov 2015 19:21:48 +0530

> in case of error no need to set num_tx and num_rx = 1, because in case of error
> these variables will remain unchanged by of_property_read_u32 ie 1 only
> 
> Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>

Applied.
