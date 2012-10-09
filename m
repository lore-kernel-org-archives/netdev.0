From: David Miller <davem@davemloft.net>
Subject: Re: [patch] farsync: fix support for over 30 cards
Date: Tue, 09 Oct 2012 13:55:50 -0400 (EDT)
Message-ID: <20121009.135550.1463309187925495248.davem@davemloft.net>
References: <20121009072047.GB19159@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kevin.curtis@farsite.co.uk, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756617Ab2JIRzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 13:55:51 -0400
In-Reply-To: <20121009072047.GB19159@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 9 Oct 2012 10:20:48 +0300

> We're trying to fill a 64 bit bitmap but only the lower 30 shifts work
> because the shift wraps around.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
