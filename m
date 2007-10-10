From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][BNX2]: Fix remote PHY media detection problems.
Date: Wed, 10 Oct 2007 16:16:39 -0700 (PDT)
Message-ID: <20071010.161639.66656718.davem@davemloft.net>
References: <1192060892.6534.4.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60264
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751771AbXJJXQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 19:16:36 -0400
In-Reply-To: <1192060892.6534.4.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 10 Oct 2007 17:01:32 -0700

> [BNX2]: Fix remote PHY media detection problems.
> 
> The remote PHY media type and link status can change between
> ->probe() and ->open().  For correct operation, we need to get the
> new status again during ->open().
> 
> The ethtool link test and loopback test are also fixed to work with
> remote PHY.  PHY loopback is simply skipped when remote PHY is
> present.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
