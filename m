From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth: Ack IRQ events as late as possible.
Date: Tue, 29 Apr 2008 01:51:40 -0400
Message-ID: <4816B76C.3080101@garzik.org>
References: <1209138209-8073-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang <LeoLi@freescale.com>, Netdev <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57868 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755161AbYD2Fvq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 01:51:46 -0400
In-Reply-To: <1209138209-8073-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> Late acking of IRQ events will reduce number of interrupts
> that needs to be served.
> 
> Makes the system somewhat responsive during a
> ping -f -l 10
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
>  drivers/net/ucc_geth.c |   36 ++++++++++++++++++++++--------------
>  drivers/net/ucc_geth.h |    4 ++--
>  2 files changed, 24 insertions(+), 16 deletions(-)

maintainer acks?


