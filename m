From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net sched: cleanup and rate limit warning
Date: Thu, 13 May 2010 09:26:43 -0700
Message-ID: <20100513092643.6551cb48@nehalam>
References: <20100511172412.76aff184@nehalam>
	<1273684674.16074.0.camel@bigi>
	<20100512111706.616dc7cf@nehalam>
	<1273691628.16074.15.camel@bigi>
	<20100512132042.3b38da18@nehalam>
	<1273696903.16074.25.camel@bigi>
	<4BEBFAD4.1030608@trash.net>
	<1273767626.6117.3.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40725 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758986Ab0EMQ0q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 12:26:46 -0400
In-Reply-To: <1273767626.6117.3.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 May 2010 12:20:26 -0400
jamal <hadi@cyberus.ca> wrote:

> On Thu, 2010-05-13 at 15:12 +0200, Patrick McHardy wrote:
> 
> > I don't remeber ever discussing that, the choice of "reclassify" as
> > default precedes TC actions and is already present in the oldest
> > iproute2 version I could find (2.2.4-ss000225).
> 
> I think i confused it with unrelated discussion.
> 
> If its been there from day 0 then we should leave it as is - rationale:
> it will help to catch config bugs.
> Stephen needs to fix his tool regardless...
> 
> cheers,
> jamal
> 

And the kernel message needs to be fixed to prevent total
log overload for the next poor sop who makes the same mistake.

Please accept the patch.

-- 
