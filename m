From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 7 Oct 2008 23:20:56 +0200
Message-ID: <20081007232056.036e26e6@speedy>
References: <m37i8k3hv1.fsf@ursa.amorsen.dk>
	<48EB5D28.7000503@cosmosbay.com>
	<20081007160729.60c076c4@speedy>
	<20081007.135548.56141000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, benny+usenet@amorsen.dk, minyard@acm.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47158 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757432AbYJGVVE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2008 17:21:04 -0400
In-Reply-To: <20081007.135548.56141000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 07 Oct 2008 13:55:48 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Tue, 7 Oct 2008 16:07:29 +0200
> 
> > The idea of keeping chains short is the problem. That code should
> > just be pulled because it doesn't help that much, and also creates
> > bias on the port randomization.
> 
> I have that patch from Vitaly Mayatskikh which does exactly this.
> 
> I keep looking at it, but I can't bring myself to apply it since
> I'm not completely convinced.

Some one on a busy server should run it and measure the delta in hash chains.
I would, but don't run anything that has more than a few UDP's open.
