From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: can: c_can: Reduce interrupt load by 50%
Date: Tue, 18 Mar 2014 21:43:39 +0100 (CET)
Message-ID: <alpine.DEB.2.02.1403182142390.18573@ionos.tec.linutronix.de>
References: <20140318171007.528610837@linutronix.de>  <20140318171127.923041002@linutronix.de>  <alpine.DEB.2.02.1403182114470.18573@ionos.tec.linutronix.de> <1395174900.2812.87.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Markus Pargmann <mpa@pengutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395174900.2812.87.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 18 Mar 2014, Joe Perches wrote:

> On Tue, 2014-03-18 at 21:18 +0100, Thomas Gleixner wrote:
> > The driver handles pointlessly TWO interrupts per packet. The reason
> > is that it enables the status interrupt which fires for each rx and tx
> > packet and it enables the per message object interrupts as well.
> 
> Are the message object interrupts a possible workaround
> for any defective hardware?

Nope. I already explained what they are for, but you snipped that
part.
 
> > performance improment
> 
> Now that the code's not being written by amateurs?

You found a typo. Great, you can keep it!
