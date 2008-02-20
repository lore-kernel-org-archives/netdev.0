From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fs_enet: Don't call phy_mii_ioctl() in atomic context.
Date: Wed, 20 Feb 2008 11:50:51 -0500
Message-ID: <47BC5A6B.1030304@pobox.com>
References: <20080215210804.GA14468@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Rune Torgersen <runet@innovsys.com>
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48784 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228AbYBTQuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:50:54 -0500
In-Reply-To: <20080215210804.GA14468@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:
> The lock acquisition in fs_ioctl() does not appear to actually be necessary,
> and thus is simply removed.
> 
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
> This fixes the following bug:
> http://ozlabs.org/pipermail/linuxppc-dev/2008-February/051564.html
> 
>  drivers/net/fs_enet/fs_enet-main.c |    7 +------
>  1 files changed, 1 insertions(+), 6 deletions(-)

applied


