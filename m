From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] ethtool: Add LRO support
Date: Thu, 09 Aug 2007 15:00:14 -0700 (PDT)
Message-ID: <20070809.150014.32064726.davem@davemloft.net>
References: <20070809164117.9907.23351.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, ossthema@de.ibm.com
To: auke-jan.h.kok@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58026
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751547AbXHIWAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 18:00:14 -0400
In-Reply-To: <20070809164117.9907.23351.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Thu, 09 Aug 2007 09:41:17 -0700

> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

I think this is definitely how we should handle LRO
configuration instead of the ad-hoc module parameters
current LRO drivers use now.

I'll put this infrastructure into net-2.6.24, it would
be nice if the EHEA and myri10g folks submitted conversions.

Thanks.
