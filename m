From: David Miller <davem@davemloft.net>
Subject: Re: [patch 2/2] dcb: use after free in dcb_flushapp()
Date: Thu, 06 Jan 2011 11:17:12 -0800 (PST)
Message-ID: <20110106.111712.183045224.davem@davemloft.net>
References: <20110105070344.GB24847@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.r.fastabend@intel.com,
	shmulikr@broadcom.com, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38460
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752465Ab1AFTQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 14:16:40 -0500
In-Reply-To: <20110105070344.GB24847@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 5 Jan 2011 10:03:44 +0300

> The original code has a use after free bug because it's not using the
> _safe() version of the list_for_each_entry() macro.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Also applied.
