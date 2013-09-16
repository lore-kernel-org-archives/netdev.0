From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: oops in __rcu_read_lock on mirabox
Date: Mon, 16 Sep 2013 19:28:07 +0100
Message-ID: <20130916182807.GO12758@n2100.arm.linux.org.uk>
References: <CACzLR4tTvt+ROEhkXUCQhV6=bPPTX4LFSkWfrEhF+OdM1Jm1Rw@mail.gmail.com> <20130915205701.5c61a444@skate> <20130916065047.GH27487@1wt.eu> <20130916175152.4e013457@skate> <CACzLR4twTNjzU8hK3L1cYUXnEH1ydwY6jnYoOG+9vLB3-4uQ4w@mail.gmail.com> <20130916163937.GC3188@1wt.eu> <20130916164412.GD3188@1wt.eu> <CACzLR4ssOPsmYaEh2ohe4HL5j+67keDYnmR4YezNB=aO7Pj5kA@mail.gmail.com> <20130916174708.GG3188@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ethan Tuttle <ethan@ethantuttle.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory =?iso-8859-1?Q?Cl=E9ment?=
	<gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:54972 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909Ab3IPS3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 14:29:01 -0400
Content-Disposition: inline
In-Reply-To: <20130916174708.GG3188@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 16, 2013 at 07:47:08PM +0200, Willy Tarreau wrote:
> I'll have to rebuild with your config and exact 3.11 to test again.
> Can you check the packet rate of your ping flood to give an order of
> magnitude so that we're sure to be in the same conditions ?

Also, try swapping kernel binaries between yourselves, so that you can
be sure you're running the exact same kernel on different hardware.
