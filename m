From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] netxen: Load firmware during probe, dma watchdog
 fix.
Date: Tue, 24 Jul 2007 16:36:37 -0400
Message-ID: <46A662D5.3020201@garzik.org>
References: <20070719091108.839200259@netxen.com> <20070719091131.467737478@netxen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rob@netxen.com,
	Milan Bag <mbag@netxen.com>, Wen Xiong <wenxiong@us.ibm.com>
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58969 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757430AbXGXUgk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 16:36:40 -0400
In-Reply-To: <20070719091131.467737478@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

dhananjay@netxen.com wrote:
> The firmware should be loaded after resetting hardware during PCI probe,
> besides module unload. This fixes issue with 2nd port of multiport adapter
> on powerpc blades. This patch also fixes a bug that PCI resources are not
> freed if dma watchdog shutdown failed. The dma watchdog poll messages
> during module unload are also suppressed.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
> Signed-off-by: Milan Bag <mbag@netxen.com>
> Signed-off-by: Wen Xiong <wenxiong@us.ibm.com>

applied


