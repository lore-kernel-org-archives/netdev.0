From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: copy traffic class from ping request to
 reply
Date: Tue, 14 Jan 2014 15:09:43 -0800 (PST)
Message-ID: <20140114.150943.20379234389119231.davem@davemloft.net>
References: <trinity-4fd0752d-8ed9-432f-aa23-28055f886c4a-1389191682248@3capp-gmx-bs32>
	<20140111105546.GB30388@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: simon-schneider@gmx.net, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53220 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbaANXJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 18:09:44 -0500
In-Reply-To: <20140111105546.GB30388@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Sat, 11 Jan 2014 11:55:46 +0100

> Suggested-by: Simon Schneider <simon-schneider@gmx.net>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

This matches ipv4 behavior (except ipv4 accomplishes this by adjusting
the ICMP socket TOS value every packet response), so applied, thanks!
