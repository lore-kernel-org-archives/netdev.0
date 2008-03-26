From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Improvev netconsole support for RTL8139 NIC driver
Date: Tue, 25 Mar 2008 23:48:20 -0400
Message-ID: <47E9C784.6050807@garzik.org>
References: <47E9B39C.5010502@pobox.com>	<20080325.194221.16658596.davem@davemloft.net>	<47E9BF7B.3030003@pobox.com> <20080325.203043.196469543.davem@davemloft.net> <47E9C56F.2070508@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yang.shi@windriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39358 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752234AbYCZDsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:48:23 -0400
In-Reply-To: <47E9C56F.2070508@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> I am being realistic...  it's
> 
> * not needed
> * increases code size
> * increases number of CPU instructions executed
> * not needed

I also wonder if using spin_lock_irqsave() makes moving to a real-time 
kernel with interrupt threads more difficult for that driver.

And of course we're talking about a hot path here.

	Jeff


