From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] natsemi: netpoll fixes
Date: Tue, 06 Mar 2007 06:10:41 -0500
Message-ID: <45ED4C31.3080902@garzik.org>
References: <200703052310.08359.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mhuth@mvista.com
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53170 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965844AbXCFLKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:10:43 -0500
In-Reply-To: <200703052310.08359.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov wrote:
> Fix two issues in this driver's netpoll path: one usual, with spin_unlock_irq()
> enabling interrupts which nobody asks it to do (that has been fixed recently in
> a number of drivers) and one unusual, with poll_controller() method possibly
> causing loss of interrupts due to the interrupt status register being cleared
> by a simple read and the interrpupt handler simply storing it, not accumulating.
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>
> 
> ---
>  drivers/net/natsemi.c |   24 +++++++++++++++++++-----
>  1 files changed, 19 insertions(+), 5 deletions(-)

applied


