From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCH 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 8 Jun 2006 09:36:26 -0600
Message-ID: <20060608153626.GE8246@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608152221.GC8246@colo.lackof.org> <44884317.8070601@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Val Henson <val.henson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:28381 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S964876AbWFHPg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 11:36:27 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <44884317.8070601@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 11:32:39AM -0400, Jeff Garzik wrote:
> >The chip IRQ gets turned off in tulip_down().
> >It won't be screaming for very long.
> 
> Then you admit that you add a race.

Yes - I realized that after I hit <send> :(

...
> >In the shared IRQ case, I expect free_irq() to unlink this instance
> >of the tulip interrupt handler from the CPU vector list. If that
> 
> Irrelevant -- that doesn't stop the tulip hardware from raising the irq, 
> nor stop the system from attempting to deliver it [in all cases].  In 
> the shared interrupt case, that means that another driver's irq handler 
> will be called for an event tulip hardware raised.

*nod*

thanks,
grant
