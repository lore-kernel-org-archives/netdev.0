From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Check if user has CAP_NET_ADMIN to change congestion
 control algorithm
Date: Fri, 27 Oct 2006 07:41:02 -0700
Message-ID: <20061027074102.2a6fef4b@localhost.localdomain>
References: <4540F076.70801@psc.edu>
	<20061026224407.GA2018@c3po.0xdef.net>
	<20061026235256.GB2018@c3po.0xdef.net>
	<20061026.170221.99202188.davem@davemloft.net>
	<20061027104311.GB3967@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:6304 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750856AbWJ0Ol4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 10:41:56 -0400
To: Hagen Paul Pfeifer <hagen@jauu.net>
In-Reply-To: <20061027104311.GB3967@c3po.0xdef.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Oct 2006 12:43:11 +0200
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> * David Miller | 2006-10-26 17:02:21 [-0700]:
> 
> >Your email client turned the tabs into spaces in the patch making it
> >useless.
> 
> Sorry my mistake! I am en route and I paste the patch into my editor, who eat
> all tabs. One more time: sorry!
> 
> 
> Check if user has CAP_NET_ADMIN capability to change
> congestion control algorithm.
> 
> 
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Please no, it makes the socket option useless.
If you want to tag some "bad apples" thats okay, but would need
some more infrastructure.
