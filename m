From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] bna: off by one in bfa_msgq_rspq_pi_update()
Date: Fri, 26 Aug 2011 12:51:51 -0400 (EDT)
Message-ID: <20110826.125151.231397633353837929.davem@davemloft.net>
References: <20110824113028.GD5975@shale.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, ddutt@brocade.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58669 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755381Ab1HZQwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:52:54 -0400
In-Reply-To: <20110824113028.GD5975@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 24 Aug 2011 14:30:28 +0300

> The rspq->rsphdlr[] array has BFI_MC_MAX elements, so this test was
> off by one.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
