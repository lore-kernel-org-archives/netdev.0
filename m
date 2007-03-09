From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] e1000: FIX: be ready for incoming irq at pci_request_irq
Date: Fri, 09 Mar 2007 11:46:52 -0500
Message-ID: <45F18F7C.3030801@garzik.org>
References: <20070306165721.27434.23796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, john.ronciak@intel.com,
	jesse.brandeburg@intel.com
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57686 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767386AbXCIQq5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:46:57 -0500
In-Reply-To: <20070306165721.27434.23796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> 
> DEBUG_SHIRQ code exposed that e1000 was not ready for incoming interrupts
> after having called pci_request_irq. This obviously requires us to finish
> our software setup which assigns the irq handler before we request the
> irq.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   66 +++++++++++++++++++++++++++-------------
>  1 files changed, 45 insertions(+), 21 deletions(-)

All these do indeed look like fixes to me.  But they look like low 
priority fixes that would need some public testing behind them, and it's 
pretty late in the 2.6.21-rc game.

I'll merge them into an e1000-fixes branch for now (and propagates 
through #ALL to akpm's -mm).  If replies to this email indicate we 
really should push these upstream for 2.6.21-rc, it will be easy enough 
to do so via #e1000-fixes.

	Jeff



