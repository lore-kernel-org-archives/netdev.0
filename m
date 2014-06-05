From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/6] pch_gbe: print invalid MAC address during probe
Date: Thu, 05 Jun 2014 15:19:29 -0700 (PDT)
Message-ID: <20140605.151929.853679355962389356.davem@davemloft.net>
References: <1401958387-8154-1-git-send-email-alexander.stein@systec-electronic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.krueger@systec-electronic.com, netdev@vger.kernel.org
To: alexander.stein@systec-electronic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180AbaFEWTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:19:30 -0400
In-Reply-To: <1401958387-8154-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Stein <alexander.stein@systec-electronic.com>
Date: Thu,  5 Jun 2014 10:53:02 +0200

> From: Daniel Krueger <daniel.krueger@systec-electronic.com>
> 
> It is also neat to show the actual offending MAC address instead of just
> rejecting it
> 
> Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
> Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
> ---
> 
> Changes in v2:
> * Use just a single line

I agree with other's feedback in that this code is not legitimate.

It should generate a random MAC address via the standard interfaces we
have for doing so, rather than failing to bring up the interface.

Interface bringup failure should be the absolute last resort, and we
should recover and still bring the interface up whenever we can.
