From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix ethernet multicast for ucc_geth.
Date: Mon, 29 Oct 2007 06:11:20 -0400
Message-ID: <4725B1C8.7010506@garzik.org>
References: <1192611942.7848.19.camel@gentoo-jocke.transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Li Yang-r58472 <LeoLi@freescale.com>
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54805 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757817AbXJ2KLW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 06:11:22 -0400
In-Reply-To: <1192611942.7848.19.camel@gentoo-jocke.transmode.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joakim Tjernlund wrote:
>>From 5761a9e5924b34615c748fba2dcb977ed04c1243 Mon Sep 17 00:00:00 2001
> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: Wed, 17 Oct 2007 11:01:44 +0200
> Subject: [PATCH] Fix ethernet multicast for ucc_geth.
>  hw_add_addr_in_hash() already swaps byte
>  order, don't do it in ucc_geth_set_multi() too.
> 
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
>  drivers/net/ucc_geth.c |   15 ++-------------
>  1 files changed, 2 insertions(+), 13 deletions(-)

applied


