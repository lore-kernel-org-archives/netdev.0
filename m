From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ptp_pch: depends on PCI
Date: Mon, 27 May 2013 15:33:10 +0100
Message-ID: <1369665190.3469.344.camel@deadeye.wl.decadent.org.uk>
References: <20130525165507.GE30204@redacted.bos.redhat.com>
	 <20130525.231129.392417150870789444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <kyle@redhat.com>, <netdev@vger.kernel.org>,
	<richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33896 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758054Ab3E0OdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 10:33:16 -0400
In-Reply-To: <20130525.231129.392417150870789444.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-05-25 at 23:11 -0700, David Miller wrote:
> From: Kyle McMartin <kyle@redhat.com>
> Date: Sat, 25 May 2013 12:55:07 -0400
> 
> > It's only accessible via PCI, but has no dependencies, so it ends up
> > being selected on s390 where a bunch of primitives only exist if
> > CONFIG_PCI=y (such as {request,free}_irq)
> > 
> > Signed-off-by: Kyle McMartin <kyle@redhat.com>
> 
> I've already told the s390 people they have to fix this properly.
> 
> They have to provide stubs for request_irq() et al. when CONFIG_PCI
> is not enabled.
> 
> This Kconfig change is therefore not appropriate.

You are quite right about request_irq(), but this is a PCI driver.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
