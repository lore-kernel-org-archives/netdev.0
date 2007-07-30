From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [2.6.22] Fix a potential NULL pointer dereference in
 mace_interrupt() in drivers/net/pcmcia/nmclan_cs.c
Date: Mon, 30 Jul 2007 15:59:25 -0400
Message-ID: <46AE431D.2000808@garzik.org>
References: <46A567A8.6050409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Micah Gruber <micah.gruber@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33887 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937744AbXG3T71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 15:59:27 -0400
In-Reply-To: <46A567A8.6050409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Micah Gruber wrote:
> This patch fixes a potential null dereference bug where we dereference 
> DEV before a null check. This patch simply moves the dereferencing after 
> the null check.
> 
> Signed-off-by: Micah Gruber <micah.gruber@gmail.com>

applied (git-am worked!)


