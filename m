From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/2] dcb: unlock on error in dcbnl_ieee_get()
Date: Thu, 06 Jan 2011 11:17:06 -0800 (PST)
Message-ID: <20110106.111706.112600632.davem@davemloft.net>
References: <20110105070312.GA24847@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	shmulikr@broadcom.com, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751815Ab1AFTQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 14:16:34 -0500
In-Reply-To: <20110105070312.GA24847@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 5 Jan 2011 10:03:12 +0300

> There is a "goto nla_put_failure" hidden inside the NLA_PUT() macro, but
> we're holding the dcb_lock so we need to unlock first.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
