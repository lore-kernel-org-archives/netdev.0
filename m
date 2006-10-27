From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 14:59:13 -0700
Message-ID: <20061027145913.04dc0e5f@dxpl.pdx.osdl.net>
References: <20061027103016.3e8514d7@freekitty>
	<20061027.141749.41635827.davem@davemloft.net>
	<20061027142402.07a47f3f@freekitty>
	<20061027.143701.85411558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:21210 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750732AbWJ0V7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 17:59:33 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061027.143701.85411558.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Oct 2006 14:37:01 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 27 Oct 2006 14:24:02 -0700
> 
> > Only some (very few) have any bad consequences. So the typical
> > distribution should be able to switch with most available for everyone,
> > and only a few needing special privileges.
> 
> I would strongly disagree as we've had several OOPS'er class bugs in
> the less frequently used algorithms.
> 

Then tag those as restricted.  Why should we keep app's away from
the simple ones.
