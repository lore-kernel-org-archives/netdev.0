From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net phylib: Remove unnecessary condition check
Date: Tue, 08 Apr 2014 13:03:45 -0400 (EDT)
Message-ID: <20140408.130345.2291211656267642777.davem@davemloft.net>
References: <534413E1.8070205@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757376AbaDHRDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 13:03:47 -0400
In-Reply-To: <534413E1.8070205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Tue, 08 Apr 2014 20:51:05 +0530

> This condition check makes no difference in the code flow since 3.10
> 
> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Your patch is still being corrupted by your email client.

> -			/* If we have the magic_aneg bit, we try again */
> -			if (phydev->drv->flags & PHY_HAS_MAGICANEG)
> -				break;
> -		}
> 		break;

On that break; line there should be a space then TAB characters in the patch,
instead there are only TAB characters.
