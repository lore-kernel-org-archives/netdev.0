From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 10/11][TG3]: Reduce spurious interrupts.
Date: Fri, 4 May 2007 19:50:10 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC0940105@nt-irva-0751.brcm.ad.broadcom.com>
References: <20070504.194207.82054727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3298 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755438AbXEECuo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 22:50:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070504.194207.82054727.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> From: "Michael Chan" <mchan@broadcom.com>
> Date: Fri, 04 May 2007 18:45:58 -0700
> 
> > We had a discussion about 2 years ago and David decided to 
> > remove the I/O read to improve performance.  Since then a
> > small number of users have been complaining about spurious
> > interrupts.  We can add back the unconditional read or do
> > this detection thing which I agree is somewhat annoying.
> > David, what do you think?
> 
> If we get an extra interrupt, we should just silently ignore it.
> 
> The performance impact of adding that thing back is just too great.
> 

In a small number of cases, we really get a ton of spurious interrupts.
We have even seen the kernel shutting off IRQ7 because of too many
unclaimed spurious interrupts.

