From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] connector: use nlmsg_put() instead of NLMSG_PUT()
 macro.
Date: Tue, 26 Jun 2012 21:14:45 -0700 (PDT)
Message-ID: <20120626.211445.403519457708632249.davem@davemloft.net>
References: <1340725284-21698-1-git-send-email-javier.martinez@collabora.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, netdev@vger.kernel.org
To: javier.martinez@collabora.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39012 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714Ab2F0EOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 00:14:46 -0400
In-Reply-To: <1340725284-21698-1-git-send-email-javier.martinez@collabora.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Martinez Canillas <javier.martinez@collabora.co.uk>
Date: Tue, 26 Jun 2012 17:41:24 +0200

> The NLMSG_PUT() macro contains a hidden goto which makes the code hard
> to audit and very error prone.
> 
> While been there also use the inline function nlmsg_data() instead of the
> NLMSG_DATA() macro to do explicit type checking.
> 
> Signed-off-by: Javier Martinez Canillas <javier.martinez@collabora.co.uk>

Applied, thanks.

I'll work to convert the remaining users, good catch.
