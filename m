From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch] remove NETIF_F_TSO ifdefery
Date: Tue, 12 Dec 2006 08:26:51 -0500
Message-ID: <457EAE1B.4070906@garzik.org>
References: <1165928783.27217.600.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55475 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbWLLN0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Dec 2006 08:26:53 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <1165928783.27217.600.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Hi,
> 
> this patch removes the NETIF_F_TSO #ifdef-ery in drivers/net; this was
> for old-old-2.4 compat (even current 2.4 has NETIF_F_TSO)
> but it's time to get rid of it by now.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

Seems sane, though bnx2 and tg3 might want trivial modifications.  I 
dunno if DaveM and mchan want to keep BCM_TSO and TG3_SUPPORT_TSO 
defines (you kept them, I prefer to kill them).

	Jeff



