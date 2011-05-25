From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix memory leak of the ASCONF queue when free
 asoc
Date: Wed, 25 May 2011 17:57:04 -0400 (EDT)
Message-ID: <20110525.175704.394251370550456184.davem@davemloft.net>
References: <4DDCB432.7000903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756079Ab1EYV5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 17:57:16 -0400
In-Reply-To: <4DDCB432.7000903@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Wed, 25 May 2011 15:48:02 +0800

> If an ASCONF chunk is outstanding, then the following ASCONF
> chunk will be queued for later transmission. But when we free
> the asoc, we forget to free the ASCONF queue at the same time,
> this will cause memory leak.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
