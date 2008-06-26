From: Vitaly Bordug <vbordug@ru.mvista.com>
Subject: Re: [PATCH 2/2] fs_enet: MDIO on GPIO support
Date: Thu, 26 Jun 2008 17:55:23 +0400
Message-ID: <20080626175523.54728d07@vitb.ru.mvista.com>
References: <200805261152.37636.laurentp@cse-semaphore.com>
	<48592322.3090201@pobox.com>
	<200806181716.40362.laurentp@cse-semaphore.com>
	<200806261321.24338.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	Scott Wood <scottwood@freescale.com>, netdev@vger.kernel.org
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:5360 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752257AbYFZNzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 09:55:18 -0400
In-Reply-To: <200806261321.24338.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jun 2008 13:21:23 +0200
Laurent Pinchart <laurentp@cse-semaphore.com> wrote:

> > There should be no dependencies. When the OF GPIO support is not selected 
> > linux/of_gpio.h will define of_get_gpio() as a stub, so the fs_enet driver 
> > will fall back to the legacy binding.  
> 
> Have we reached a consensus on which tree the patch should go to ?
I think it should go through powerpc tree, not seeing too much netdev-generic stuff in here.
If noone will object, Kumar will pick it up I guess...

-- 
Sincerely, 
Vitaly
