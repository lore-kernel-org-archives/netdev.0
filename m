From: Clemens Gruber <clemens.gruber@pqgruber.com>
Subject: Re: [PATCH] phy: marvell: Fix and unify reg-init behavior
Date: Mon, 15 Feb 2016 21:14:35 +0100
Message-ID: <20160215201435.GA12064@archie.tuxnet.lan>
References: <1455558779-15953-1-git-send-email-clemens.gruber@pqgruber.com>
 <56C21695.1030809@gmail.com>
 <56C21756.1020702@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pqgruber.com ([178.189.19.235]:49729 "EHLO
	mail.pqgruber.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbcBOUOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 15:14:38 -0500
Content-Disposition: inline
In-Reply-To: <56C21756.1020702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

On Mon, Feb 15, 2016 at 10:22:14AM -0800, Florian Fainelli wrote:
> 
> 
> On 15/02/2016 10:19, Florian Fainelli wrote:
> > On 15/02/2016 09:52, Clemens Gruber wrote:
> >> For the Marvell 88E1510, marvell_of_reg_init was called too late (in
> >> m88e1510_config_aneg), which lead to the phy state machine being stuck
> >> at waiting for interrupts, which are off by default on the 88E1510.
> >> This further lead to the ethernet link not coming up at boot.
> >> For some Marvell PHYs, marvell_of_reg_init was not called at all.
> > 
> > You could mention that this became apparent with
> 
> ...
> 113c74d83eef ("net: phy: turn carrier off on phy attach")

Thanks for your comments. I thought it would be better to just leave all
PHYs with special requirements (resets, ..) as they were and only change
the behavior of those who were missing the marvell_of_reg_init calls.
What do you think?

Clemens
