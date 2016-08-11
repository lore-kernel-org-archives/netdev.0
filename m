From: Andreas Werner <andreas.werner@men.de>
Subject: Re: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Thu, 11 Aug 2016 10:58:26 +0200
Message-ID: <20160811085826.GB25813@awelinux>
References: <20160726091555.GA26227@awelinux>
 <9487fe77-dbd0-3a64-b648-cf76b897feda@grandegger.com>
 <20160808113938.GA17459@awelinux>
 <456c4f82-6a53-e821-3396-63d413db9eb7@grandegger.com>
 <20160808140546.GA1733@awelinux>
 <808e919b-8643-2113-9fde-001861883abe@grandegger.com>
 <20160809061038.GC1733@awelinux>
 <a0169f54-c8c7-5cf6-b93b-acd4a308a052@hartkopp.net>
 <20160811071458.GA25813@awelinux>
 <1d81436b-4ad2-a34f-e2e1-accde0b16a47@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andreas Werner <andreas.werner@men.de>,
	Wolfgang Grandegger <wg@grandegger.com>, <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<jthumshirn@suse.de>, <andy@wernerandy.de>,
	<michael.miehling@men.de>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1d81436b-4ad2-a34f-e2e1-accde0b16a47@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 11, 2016 at 10:45:00AM +0200, Oliver Hartkopp wrote:
> On 08/11/2016 09:14 AM, Andreas Werner wrote:
> >On Wed, Aug 10, 2016 at 10:28:45PM +0200, Oliver Hartkopp wrote:
> 
> >>Just check 'git grep IFF_ECHO'. Even grcan.c and janz-ican3.c have IFF_ECHO
> >>set - but implement it in a different way without using the provided
> >>machanism from dev.c .
> >>
> >
> >Ok I am with you.
> 
> Great :-)
> 
> >>A local loopback inside the CAN controller which is generated after
> >>successful transmit is an excellent implementation with excellent
> >>timestamps. The only problem for you is to detect the looped CAN frames and
> >>match them to the skb pointer of the outgoing frame to 'receive' the correct
> >>echo skb.
> >>
> >
> >At the moment, i think there is no way to detect those looped frames.
> >I will talk to our IC designer and discuss this issue with him. Maybe we
> >have the possibility to get a local loopback inside the CAN controller.
> >This seems to be the best way to do it.
> 
> When you still have the possibility to change the IP core I would suggest to
> create some kind of 16/32 bit value which you can pass to the CAN controller
> along with the CAN frame to be sent.
> 
> And when this frame comes back due to the loopback you can use this non-zero
> 16/32 bit value to match into a list of tx skb pointers for IFF_ECHO.
> 
> E.g. when this 16/32 bit value is zero this CAN frame obviously was received
> from another CAN node.
> 
> Just an idea.
> 

I am not sure if we have a way to change the IP but i will try to talk with
my IC designer. He will be available next week.

Your idea sounds good. I will check a few more driver to get more information
how they did the implementation.

> Regards,
> Oliver

Thanks your comments and explanations Oliver.

Regards
Andy
