From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [2.6.22] Fix a potential NULL pointer dereference in
 mace_interrupt() in drivers/net/pcmcia/nmclan_cs.c
Date: Tue, 24 Jul 2007 16:24:15 -0400
Message-ID: <46A65FEF.2030303@garzik.org>
References: <46A567A8.6050409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Micah Gruber <micah.gruber@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58860 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756112AbXGXUYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:24:18 -0400
In-Reply-To: <46A567A8.6050409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Micah Gruber wrote:
> This patch fixes a potential null dereference bug where we dereference 
> DEV before a null check. This patch simply moves the dereferencing after 
> the null check.
> 
> Signed-off-by: Micah Gruber <micah.gruber@gmail.com>
> 
> ---
> 
> --- a/drivers/net/pcmcia/nmclan_cs.c    +++ 
> b/drivers/net/pcmcia/nmclan_cs.c    @@ -996,7 +996,7 @@

PLEASE PLEASE PLEASE fix your mailer.

None of your patches are apply-able via script or patch(1), which is how 
all Linux maintainers apply patches.

If you want to contribute to the kernel, you -must- figure out how to 
send patches via email.

Linux kernel development is done almost exclusively through email, so it 
is very important to get the details right.

	Jeff



