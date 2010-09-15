From: Brian Haley <brian.haley@hp.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del command
 to reset
Date: Wed, 15 Sep 2010 13:37:05 -0400
Message-ID: <4C910441.20107@hp.com>
References: <1282024802.2487.687.camel@edumazet-laptop> <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se> <1282050920.2448.47.camel@edumazet-laptop> <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se> <1282055659.2448.58.camel@edumazet-laptop> <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se> <20100817171115.GA4134@mcarlson.broadcom.com> <alpine.DEB.1.10.1008171928160.21857@red.crap.retrofitta.se> <20100817183112.GA4351@mcarlson.broadcom.com> <alpine.DEB.1.10.1008172035520.21857@red.crap.retrofitta.se> <20100818012318.GA4630@mcarlson.broadcom.com> <alpine.DEB.1.10.1008180900350.21857@red.crap.retrofitta.se> <alpine.DEB.1.10.1009011034560.31938@red.crap.retrofitta.se> <4C7E65DA.5020106@hp.com> <alpine.DEB.1.10.1009142134440.25664@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.1009142134440.25664@red.crap.retrofitta.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/14/2010 03:56 PM, Thomas Habets wrote:
> 
> Sorry for the late reply. I've been swamped.
> 
> On Wed, 1 Sep 2010, Brian Haley wrote:
>> So are you running with this set to "Shared Network Port" mode?  I'm
>> guessing you are.
> 
> Yes, there's no dedicated ILO port.
> 
>> There was another report on netdev back in 11/2008 on this exact
>> hardware,
>> with the same problem.
> 
> I can't seem to find it. Do you happen to have the subject line or
> something?

It was actually a month earlier in 2008, I mis-typed, here's the link:

http://marc.info/?l=linux-netdev&m=122280545121251&w=2

>> I dug-up my notes on the problem, and from what I can tell, the receive
>> multicast filters on the NIC were getting removed, causing both incoming
>> IPv6 and IPv4 multicast packets to get dropped.
> 
> Sounds about right. From what I understand the relevant registers were
> still the same for me when it wasn't working though (if that indeed is
> how the filter is implemented).

One of the outcomes of that investigation was to update the firmware
and/or iLO, I'm not sure if either fixed the problem.

-Brian
