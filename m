From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] be2net: Fix a bug in Rx buffer posting
Date: Wed, 08 Apr 2015 22:44:41 -0400 (EDT)
Message-ID: <20150408.224441.1432691662000312621.davem@davemloft.net>
References: <20150408215948.GA8248@OptiPlex>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbbDICou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 22:44:50 -0400
In-Reply-To: <20150408215948.GA8248@OptiPlex>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@emulex.com>
Date: Wed, 8 Apr 2015 16:59:48 -0500

> The numPosted field in the ERX Doorbell register is 8-bits wide.
> So the max buffers that we can post at a time is 255 and not 256
> which we are doing currently.
> 
> Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Applied, thanks.
