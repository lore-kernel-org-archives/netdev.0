From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] bcm43xx: iw_priv_args names should be <16 characters
Date: Thu, 13 Apr 2006 10:29:19 -0700
Message-ID: <20060413102919.5e0bdb2e@localhost.localdomain>
References: <20060413130227.GD20839@harddisk-recovery.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:145 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750835AbWDMR3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2006 13:29:34 -0400
To: Erik Mouw <erik@harddisk-recovery.com>
In-Reply-To: <20060413130227.GD20839@harddisk-recovery.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Apr 2006 15:02:27 +0200
Erik Mouw <erik@harddisk-recovery.com> wrote:

> The room for the names in bcm43xx_priv_wx_args[] are IFNAMSIZ long and
> IFNAMSIZ is defined as 16, so the names in bcm43xx_priv_wx_args should
> be 15 characters (16 including the trailing \0). This patch fixes that
> for the "set_shortpreambl", "get_shortpreambl", "set_swencryption", and
> "get_swencryption" private calls. Patch is against 2.6.17-rc1.
> 
> Signed-off-by: Erik Mouw <erik@harddisk-recovery.com>

Shouldn't compiler have gagged on this?
