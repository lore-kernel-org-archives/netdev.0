From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: mdio: of_mdiobus_register(): fall back to mdiobus_register()
 for !CONFIG_OF
Date: Wed, 7 May 2014 12:22:25 +0530
Message-ID: <5369D829.6080802@ti.com>
References: <1399395136-12139-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Daniel Mack <zonque@gmail.com>, <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:45670 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750996AbaEGGwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 02:52:30 -0400
In-Reply-To: <1399395136-12139-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 06 May 2014 10:22 PM, Daniel Mack wrote:
> If CONFIG_OF is not set, make of_mdiobus_register() call
> mdiobus_register() instead of returning -ENOSYS.
>
> This way, we can just call of_mdiobus_register() from all DT-enabled
> drivers to handle the compat cases.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
