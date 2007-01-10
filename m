From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: BUG: soft lockup detected on CPU#0! (2.6.18.2 plus hacks)
Date: Wed, 10 Jan 2007 13:50:48 +0100
Message-ID: <20070110125048.GB2611@ff.dom.local>
References: <OF02F7C182.A05F7E5A-ON88257259.001B0EFA-88257259.001E96CF@us.ibm.com> <E1H2M3X-0001HE-00@gondolin.me.apana.org.au> <20070104.123333.91315611.davem@davemloft.net> <459EB627.5040606@candelatech.com> <20070108065346.GA1665@ff.dom.local> <45A277E6.6000904@candelatech.com> <20070108100350.1187a3dc@freekitty> <20070109081045.GA1703@ff.dom.local> <20070110090411.GA1589@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, dlstevens@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:38410 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932787AbXAJMsy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 07:48:54 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20070110090411.GA1589@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 10, 2007 at 10:04:11AM +0100, Jarek Poplawski wrote:
...
> It looks like you're talking about the right thing
> and I'm a fool again! Now I try to find why I even 
> had to pay for this. I read again and again adequate
> chapters from R. Love and C. Benvenuti's books, see
> a lot about kernel preemption in 2.6, but can't see
> anything about preemption disabled in ioctls - maybe
> I'm blind or they are badly translated. Now I look
> into "Linux Device Drivers", see ch. 6 about ioctls,
> blocking I/O and RCU, but nothing about preemption
> disabled again. Maybe this is omited because it's
> obvious to people who started hacking with earlier
> kernels?

... or maybe it's even more complicated...

For the time being, I revoke my critique of these books.

Jarek P. 
