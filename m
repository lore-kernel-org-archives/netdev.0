From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] tcp: don't allow unfair congestion control to be built
 without warning
Date: Fri, 27 Oct 2006 14:24:02 -0700
Message-ID: <20061027142402.07a47f3f@freekitty>
References: <20061027152157.GB4632@c3po.0xdef.net>
	<45422A31.7070806@osdl.org>
	<20061027103016.3e8514d7@freekitty>
	<20061027.141749.41635827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55759 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752474AbWJ0VYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 17:24:20 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061027.141749.41635827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Oct 2006 14:17:49 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Fri, 27 Oct 2006 10:30:16 -0700
> 
> > My proposed method restricting TCP choices to fair algorithms.
> > This a net wide, not system wide issue, it should not be done
> > by kernel policy choice (capability), but by a build choice.
> 
> I think this sucks even worse than the current situation.
> 
> How difficult is it to understand that an administrator might
> like to be able to build in and experiment with some congestion
> control algorithms, yet still be able to keep his normal users
> from using them?

Only some (very few) have any bad consequences. So the typical
distribution should be able to switch with most available for everyone,
and only a few needing special privileges.


-- 
Stephen Hemminger <shemminger@osdl.org>
