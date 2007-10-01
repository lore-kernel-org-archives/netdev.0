From: Jeff Garzik <jeff@garzik.org>
Subject: Re: sk98lin, jumbo frames, and memory fragmentation
Date: Mon, 01 Oct 2007 16:47:28 -0400
Message-ID: <47015CE0.3080706@garzik.org>
References: <47015A24.7000701@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux@syskonnect.de, netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54977 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091AbXJAUrf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 16:47:35 -0400
In-Reply-To: <47015A24.7000701@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen wrote:
> We're considering some hardware that uses the sk98lin network hardware, 
> and we'll be using jumbo frames.  Looking at the driver, when using a 
> 9KB MTU it seems like it would end up trying to atomically allocate a 
> 16KB buffer.

The sk98lin driver is going away, please don't use it.

It's unmaintained and full of known bugs.

	Jeff



