From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND #3/patch 2.6.26-rc6] net/enc28j60: low power mode
Date: Tue, 17 Jun 2008 23:26:27 -0400
Message-ID: <48588063.4020304@garzik.org>
References: <200806122138.06674.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Claudio Lanconelli <lanconelli.claudio@eptar.com>,
	lkml <linux-kernel@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40551 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758108AbYFRD0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 23:26:30 -0400
In-Reply-To: <200806122138.06674.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Brownell wrote:
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
> ---
> Previously sent:  18-May, 19-February; there were several
> previous iterations too ...
> 
>  drivers/net/enc28j60.c |   82 ++++++++++++++++++++++++++++++++++---------------
>  1 file changed, 58 insertions(+), 24 deletions(-)

applied


