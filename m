From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] e1000: fix schedule while atomic when called from
 mii-tool
Date: Tue, 13 Nov 2007 21:00:31 -0800 (PST)
Message-ID: <20071113.210031.09862973.davem@davemloft.net>
References: <20071113231110.13177.27339.stgit@localhost.localdomain>
	<20071113231138.13177.67320.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750716AbXKNFAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:00:32 -0500
In-Reply-To: <20071113231138.13177.67320.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Tue, 13 Nov 2007 15:11:38 -0800

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> mii-tool can cause the driver to call msleep during nway reset,
> bugzilla.kernel.org bug 8430.  Fix by simply calling reinit_locked
> outside of the spinlock, which is safe from ethtool, so it should be
> safe from here.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

Looks good.

A bug fix, so queued to net-2.6, thanks.
