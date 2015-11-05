From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] qlogic/qed: remove bogus NULL check
Date: Wed, 04 Nov 2015 22:06:30 -0500 (EST)
Message-ID: <20151104.220630.829229766192345475.davem@davemloft.net>
References: <20151104132716.GD20966@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031599AbbKEDGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2015 22:06:33 -0500
In-Reply-To: <20151104132716.GD20966@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 4 Nov 2015 16:27:16 +0300

> We check if "p_hwfn" is NULL and then dereference it in the error
> handling code.  I read the code and it isn't NULL so let's remove the
> check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
