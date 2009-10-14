From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PF_RING: Include in main line kernel?
Date: Thu, 15 Oct 2009 00:36:40 +0400
Message-ID: <20091014203640.GB32317@ioremap.net>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com> <20091014090125.535ee0dc@nehalam> <a07586b0910141002m2a9f4466j412245fdae4e5372@mail.gmail.com> <20091014123328.1ebe35ea@s6510> <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Brad Doctor <brad.doctor@gmail.com>, netdev@vger.kernel.org
To: Luca Deri <deri@ntop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:59174 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933881AbZJNUhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 16:37:18 -0400
Content-Disposition: inline
In-Reply-To: <8B385E10-4BE2-48A6-BDE0-0AA1A603275E@ntop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2009 at 10:17:30PM +0200, Luca Deri (deri@ntop.org) wrote:
> The reason why I decided to patch dev.c is because I wanted PF_RING to  
> decide whether the packet journey shall continue or not. In other  
> words with my solution PF_RING applications can decide whether the  
> received packets will also be delivered to upper layers (and to other  
> kernel network components). This configurable 'early packet drop'  
> allows the overall performance to be significantly increased as  
> received packets are not supposed to be delivered to upper layers;  
> this is a typical situations for many monitoring devices.

This is a feature many projects implement themself indeed. What about
creating special return value from the packet handler which will
indicate that packet was already consumed and no further work should be
done on it?

-- 
	Evgeniy Polyakov
