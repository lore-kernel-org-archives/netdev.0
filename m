From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] gianfar: fix phc index build failure
Date: Fri, 21 Sep 2012 13:46:25 -0400 (EDT)
Message-ID: <20120921.134625.1115754127699712178.davem@davemloft.net>
References: <cover.1348203988.git.richardcochran@gmail.com>
	<cover.1348203988.git.richardcochran@gmail.com>
	<24134c2d3a9bcbe65f1becd809b98d9c2559212d.1348203988.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50890 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122Ab2IURq1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:46:27 -0400
In-Reply-To: <24134c2d3a9bcbe65f1becd809b98d9c2559212d.1348203988.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Fri, 21 Sep 2012 07:11:12 +0200

> This patch fixes a build failure introduced in commit 66636287. Not only
> was a global variable inconsistently named, but also it was not exported
> as it should have been.
> 
> This fix is also needed in stable version 3.5.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>

Applied and queued up for -stable, thanks.

> Cc: <stable@vger.kernel.org>

Do not add -stable CC:'s to networking patches, please instead simply
ask me to queue it up for -stable as I take care of networking stable
submissions myself rather than via the automated procedure.
