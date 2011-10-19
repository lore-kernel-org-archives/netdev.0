From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 00:16:10 -0400 (EDT)
Message-ID: <20111019.001610.312990203017422173.davem@davemloft.net>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	<cover.1318498805.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	johannes@sipsolutions.net
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122Ab1JSERS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 00:17:18 -0400
In-Reply-To: <cover.1318498805.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Thu, 13 Oct 2011 11:46:26 +0200

> The first patch fixes a bug in the time stamping code introduced in
> v2.6.36 of the kernel.
> 
> The other two patches depend on the first patch and fix two bugs in a
> PTP Hardware Clock driver. This driver was first introduced in Linux
> version 3.0.
> 
> Richard Cochran (3):
>   net: hold sock reference while processing tx timestamps
>   dp83640: use proper function to free transmit time stamping packets
>   dp83640: free packet queues on remove

Johannes and Eric, please help review Richard's fixes here.

Thanks!
