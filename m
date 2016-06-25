From: Max Filippov <jcmvbkbc@gmail.com>
Subject: Re: [PATCH 1/2] net: ethernet: ethoc: use phydev from struct
 net_device
Date: Sat, 25 Jun 2016 21:31:09 +0300
Message-ID: <20160625183109.GA10453@octofox.metropolis>
References: <1466865222-11840-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andrew@lunn.ch, tklauser@distanz.ch,
	colin.king@canonical.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34589 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbcFYSbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 14:31:18 -0400
Content-Disposition: inline
In-Reply-To: <1466865222-11840-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 25, 2016 at 04:33:41PM +0200, Philippe Reynes wrote:
> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---

Series:
Tested-by: Max Filippov <jcmvbkbc@gmail.com>

-- 
Thanks.
-- Max
