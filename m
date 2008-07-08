From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Tue, 8 Jul 2008 14:47:25 -0700
Message-ID: <20080708144725.5b663d19@infradead.org>
References: <20080707.155723.48071035.davem@davemloft.net>
	<adazlotwalk.fsf@cisco.com>
	<4873BC67.8010205@opengridcomputing.com>
	<20080708.143158.182627862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60797 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbYGHVre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 17:47:34 -0400
In-Reply-To: <20080708.143158.182627862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Jul 2008 14:31:58 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Steve Wise <swise@opengridcomputing.com>
> Date: Tue, 08 Jul 2008 14:13:43 -0500
> 
> > So should I put the rtnl acquisitions back in iw_cxgb3?  Or fix
> > cxgb3 to not assume rtnl is held?
> 
> It appears that the kernel always invokes the ethtool ops with
> RTNL held, and therefore that's the environment that needs
> to be ensured.

so for the patch that started all this... do I need to go back to the
original where I didn't use ethool?
(since this is called from irq context....)



-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
