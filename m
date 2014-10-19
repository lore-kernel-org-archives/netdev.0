From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Net: DSA: Fix checking for get_phy_flags function
Date: Sun, 19 Oct 2014 12:46:51 -0400 (EDT)
Message-ID: <20141019.124651.345090061805966642.davem@davemloft.net>
References: <1413729707-1682-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaJSQqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 12:46:53 -0400
In-Reply-To: <1413729707-1682-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 19 Oct 2014 16:41:47 +0200

> The check for the presence or not of the optional switch function
> get_phy_flags() called the function, rather than checked to see if it
> is a NULL pointer. This causes a derefernce of a NULL pointer on all
> switch chips except the sf2, the only switch to implement this call.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Fixes: 6819563e646a ("net: dsa: allow switch drivers to specify phy_device::dev_flags")
> Cc: Florian Fainelli <f.fainelli@gmail.com>

Applied.
