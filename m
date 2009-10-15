From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PF_RING: Include in main line kernel?
Date: Thu, 15 Oct 2009 11:02:34 +0400
Message-ID: <20091015070234.GA29506@ioremap.net>
References: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org> <20091014203640.GB32317@ioremap.net> <4AD64251.50903@candelatech.com> <20091014.144923.112167161.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: greearb@candelatech.com, deri@ntop.org, shemminger@vyatta.com,
	brad.doctor@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.ru ([195.178.208.66]:47980 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934679AbZJOHDM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 03:03:12 -0400
Content-Disposition: inline
In-Reply-To: <20091014.144923.112167161.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2009 at 02:49:23PM -0700, David Miller (davem@davemloft.net) wrote:
> > Maybe something similar to the attached patch?
> 
> This is not something I'm interested in applying.
> 
> It makes implementing proprietary complete networking stacks
> for Linux way too easy.

Such kernels will be tainted and thus its bugs and problems will be
clearly indicated by the proprietary module.

> Instead I'd rather have a GPL exported function that allows indication
> of consumption somehow.  That's why we have a special hook for
> bonding, so it cannot be abused in proprietary modules.

I believe bonding with its hook is a historical heritage and priority
absence in packet hooks which do not currently allow something to be
registered very first and steal packets from the stack.

Looks like bonding could be implemented as a packet handler with Ben's
patch applied, isn't it?

-- 
	Evgeniy Polyakov
