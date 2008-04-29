From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Ack IRQ events as late as possible.
Date: Tue, 29 Apr 2008 08:30:02 +0200
Message-ID: <1209450602.6904.33.camel@gentoo-jocke.transmode.se>
References: <1209138209-8073-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <4816B76C.3080101@garzik.org>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Li Yang <LeoLi@freescale.com>, Netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:3338 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753328AbYD2GaF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 02:30:05 -0400
In-Reply-To: <4816B76C.3080101@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-04-29 at 01:51 -0400, Jeff Garzik wrote:
> Joakim Tjernlund wrote:
> > Late acking of IRQ events will reduce number of interrupts
> > that needs to be served.
> > 
> > Makes the system somewhat responsive during a
> > ping -f -l 10
> > 
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> >  drivers/net/ucc_geth.c |   36 ++++++++++++++++++++++--------------
> >  drivers/net/ucc_geth.h |    4 ++--
> >  2 files changed, 24 insertions(+), 16 deletions(-)
> 
> maintainer acks?
> 

Not yet, still waiting to hear from Leo
