From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] DM9000: fix use of kfree() on net device
Date: Tue, 08 May 2007 01:17:00 -0400
Message-ID: <464007CC.1080203@garzik.org>
References: <20070507111325.GA32546@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54315 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967897AbXEHFRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 01:17:02 -0400
In-Reply-To: <20070507111325.GA32546@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Dooks wrote:
> The DM9000 network driver is calling kfree() on an netdev
> causing the system to oops if the probe fails. The right
> thing to do is call free_netdev().
> 
> Thanks to Russell King for spotting this.
> 
> Signed-off-by: Ben Dooks <ben-linux@fluff.org>

applied


