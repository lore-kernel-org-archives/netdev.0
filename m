From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] isdn: avoid copying too long drvid
Date: Tue, 29 Nov 2011 18:40:06 -0500 (EST)
Message-ID: <20111129.184006.1024419970584749707.davem@davemloft.net>
References: <20111123064345.GB6871@elgon.mountain>
	<20111124124209.GI3195@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, lucas.demarchi@profusion.mobi,
	nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44583 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941Ab1K2XlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 18:41:17 -0500
In-Reply-To: <20111124124209.GI3195@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 24 Nov 2011 15:42:09 +0300

> "cfg->drvid" comes from the user so there is a possibility they
> didn't NUL terminate it properly.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: use strnlen() instead of strlen().

Applied.
