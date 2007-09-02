From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: RTNL: assertion failed at net/core/dev.c
Date: Sun, 2 Sep 2007 20:04:09 +0200 (CEST)
Message-ID: <alpine.DEB.0.999.0709022003110.7103@sheep.housecafe.de>
References: <alpine.DEB.0.999.0709021754290.7103@sheep.housecafe.de>
 <20070902171300.2f4814d1@oldman>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=us-ascii
Cc: Christian Kujau <lists@nerdbynature.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	johannes@sipsolutions.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:49606 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752293AbXIBSEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2007 14:04:21 -0400
In-Reply-To: <20070902171300.2f4814d1@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2 Sep 2007, Stephen Hemminger wrote:
> Vendor module calls kernel api incorrectly. dev_set_promiscuity requires
> that the calling thread hold rtnl mutex (ie call rtnl_lock). It's their bug,
> netdev doesn't want to hear about it.

OK, that's all I needed to know. Thank you both for your comments!

Christian.
-- 
BOFH excuse #435:

Internet shut down due to maintenance
