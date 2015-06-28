From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix RCU lockdep warning from linkdown changes
Date: Sun, 28 Jun 2015 16:48:05 -0700 (PDT)
Message-ID: <20150628.164805.1833790953816904553.davem@davemloft.net>
References: <1435361831-1104-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergey.senozhatsky.work@gmail.com
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39202 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbbF1XsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2015 19:48:07 -0400
In-Reply-To: <1435361831-1104-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Fri, 26 Jun 2015 19:37:11 -0400

> The following lockdep splat was seen due to the wrong context for
> grabbing in_dev.
 ...
> This patch resolves that splat.
> 
> Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Applied, thanks Andy.
