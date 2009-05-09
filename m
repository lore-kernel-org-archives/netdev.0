From: David Miller <davem@davemloft.net>
Subject: Re: [patch next 2/4] netxen: fix irq tear down and msix leak.
Date: Sat, 09 May 2009 13:17:31 -0700 (PDT)
Message-ID: <20090509.131731.142224781.davem@davemloft.net>
References: <1241856150-4488-1-git-send-email-dhananjay@netxen.com>
	<1241856150-4488-2-git-send-email-dhananjay@netxen.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dhananjay@netxen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43082
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753837AbZEIURf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2009 16:17:35 -0400
In-Reply-To: <1241856150-4488-2-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Sat,  9 May 2009 01:02:28 -0700

> o Fix the order of irq and hardware context teardown.
>   Also synchronize the interrupt in dev close() before
>   releasing tx buffers.
> 
> o Fix possible msi-x vector leak if available vectors are
>   less than requested.
> 
> o Request multiple msix vectors only if hardware supports
>   multiple rx queues.
> 
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Applied.
