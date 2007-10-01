From: John Heffner <jheffner@psc.edu>
Subject: Re: sk98lin, jumbo frames, and memory fragmentation
Date: Mon, 01 Oct 2007 16:44:50 -0400
Message-ID: <47015C42.9070809@psc.edu>
References: <47015A24.7000701@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux@syskonnect.de, netdev@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:59158 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906AbXJAUo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 16:44:57 -0400
In-Reply-To: <47015A24.7000701@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yes it has this problem.  I've observed it in practice on a busy firewall.

   -John


Chris Friesen wrote:
> 
> Hi all,
> 
> We're considering some hardware that uses the sk98lin network hardware, 
> and we'll be using jumbo frames.  Looking at the driver, when using a 
> 9KB MTU it seems like it would end up trying to atomically allocate a 
> 16KB buffer.
> 
> Has anyone heard of this been a problem?  It would seem like trying to 
> atomically allocate four physically contiguous pages could become tricky 
> after the system has been running for a while.
> 
> The reason I ask is that we ran into this with the e1000.  Before they 
> added the new jumbo frame code it was trying to atomically allocate 32KB 
> buffers and we would start getting allocation failures after a month or 
> so of uptime.
> 
> Any information anyone can provide would be appreciated.
> 
> 
> Thanks,
> 
> Chris
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

