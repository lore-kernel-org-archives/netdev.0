From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] net/enc28j60: low power mode
Date: Wed, 05 Mar 2008 06:13:47 -0500
Message-ID: <47CE806B.9010102@pobox.com>
References: <47B415D3.6020200@eptar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Brownell <david-b@pacbell.net>
To: Claudio Lanconelli <lanconelli.claudio@eptar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34418 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750804AbYCELNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 06:13:53 -0500
In-Reply-To: <47B415D3.6020200@eptar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Claudio Lanconelli wrote:
> Keep enc28j60 chips in low-power mode when they're not in use.
> At typically 120 mA, these chips run hot even when idle; this
> low power mode cuts that power usage by a factor of around 100.
> 
> This version provides a generic routine to poll a register until
> its masked value equals some value ... e.g. bit set or cleared.
> It's basically what the previous wait_phy_ready() did, but this
> version is generalized to support the handshaking needed to
> enter and exit low power mode.
> 
> Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> Signed-off-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>

It's a bit silly to create a variable just to store the result of 
msecs_to_jiffies(constant)


