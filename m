From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH 2/2] netdrvr/ibmlana: move away from legacy MCA API
Date: Mon, 29 Oct 2007 20:39:51 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0710292039020.26070@fbirervta.pbzchgretzou.qr>
References: <47dcd058deaaf90802c720df243f5c8b26ed9de3.1193686354.git.jeff@garzik.org>
 <cbe6f335b6d7f4199e235a4925d1c931dd512fe5.1193686354.git.jeff@garzik.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:57493 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbXJ2Tjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 15:39:52 -0400
In-Reply-To: <cbe6f335b6d7f4199e235a4925d1c931dd512fe5.1193686354.git.jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 29 2007 15:33, Jeff Garzik wrote:
> 
>+#if 0 /* info available elsewhere, but this is kept for reference */

It is available in the git history, yes, is it still needed for reference?

>+static short ibmlana_adapter_ids[] __initdata = {
>+	IBM_LANA_ID,
>+	0x0000
>+};
>+
>+static char *ibmlana_adapter_names[] __initdata = {
>+	"IBM LAN Adapter/A",
>+	NULL
>+};

Can this be const?

