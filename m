From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: flush if we can't fit another DATA chunk
Date: Tue, 05 Apr 2016 15:41:22 -0400 (EDT)
Message-ID: <20160405.154122.24544897927296613.davem@davemloft.net>
References: <a9e4f862b5f7a43eccca5966684d172e4de57b13.1459475764.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, vyasevich@gmail.com,
	linux-sctp@vger.kernel.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751435AbcDETl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 15:41:26 -0400
In-Reply-To: <a9e4f862b5f7a43eccca5966684d172e4de57b13.1459475764.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri,  1 Apr 2016 14:05:48 -0300

> There is no point on delaying the packet if we can't fit a single byte
> of data on it anymore. So lets just reduce the threshold by the amount
> that a data chunk with 4 bytes (rounding) would use.
> 
> v2: based on the right tree
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

Applied, thanks.
