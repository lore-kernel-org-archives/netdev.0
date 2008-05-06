From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ucc_geth: Don't use RX clock as TX clock.
Date: Tue, 06 May 2008 12:28:31 -0400
Message-ID: <4820872F.1020806@garzik.org>
References: <1209467037-30612-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, Li Yang <LeoLi@freescale.com>,
	Timur Tabi <timur@freescale.com>
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60898 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765053AbYEFQ2e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:28:34 -0400
In-Reply-To: <1209467037-30612-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joakim Tjernlund wrote:
> Commit 9fb1e350e16164d56990dde036ae9c0a2fd3f634,
> ucc_geth: use rx-clock-name and tx-clock-name device tree properties
> Introduced a typo that made the driver use the RX clock
> as TX clock, causing massive TX errors.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
> 
> Resending as the first one got rejected du to missing commas.
> 
>  drivers/net/ucc_geth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied


