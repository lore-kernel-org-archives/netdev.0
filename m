From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: signal sk_data_ready earlier on data chunks
 reception
Date: Sun, 01 May 2016 21:06:28 -0400 (EDT)
Message-ID: <20160501.210628.858260753518974978.davem@davemloft.net>
References: <271eaec3c8fad125a48b5acce192dd1080c26528.1461949899.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbcEBBGb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 21:06:31 -0400
In-Reply-To: <271eaec3c8fad125a48b5acce192dd1080c26528.1461949899.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 29 Apr 2016 14:17:08 -0300

> Dave Miller pointed out that fb586f25300f ("sctp: delay calls to
> sk_data_ready() as much as possible") may insert latency specially if
> the receiving application is running on another CPU and that it would be
> better if we signalled as early as possible.
> 
> This patch thus basically inverts the logic on fb586f25300f and signals
> it as early as possible, similar to what we had before.
> 
> Fixes: fb586f25300f ("sctp: delay calls to sk_data_ready() as much as possible")
> Reported-by: Dave Miller <davem@davemloft.net>
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks Marcelo.
