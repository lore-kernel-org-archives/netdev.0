From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: e1000 speed/duplex error
Date: Tue, 1 Aug 2006 08:21:22 -0400
Message-ID: <20060801122122.GA5965@gospo.rdu.redhat.com>
References: <1301563340.20060801141827@mail.ru> <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com> <595776532.20060801160328@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <tarbal@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54731 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751265AbWHAMVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 08:21:40 -0400
To: a1 <a1k@mail.ru>
Content-Disposition: inline
In-Reply-To: <595776532.20060801160328@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 04:03:28PM +0400, a1 wrote:
> He, Jeff.
> 
> Thank for quick reply.
> 
> JK> On 8/1/06, a1 <a1k@mail.ru> wrote:
> >> I'm trying to set my nic to force 100Mb/FD, but I'm constantly getting 100/HD on
> >> other side of the link.
> >>
> >> The command is:
> >> ethtool -s eth0 speed 100 duplex full autoneg off
> >>
> >> e1000 driver version 7.1.9 (latest) downloaded from sourceforge.
> >>
> 
> JK> What are you linking to? And what is the link partner set to?
> I am linking to my 3com gigabit ethernet switch. And it shows
> 100Mbit/halfduplex.
> 
> JK> If one link partner is set to auto-negotiate, and the other partner
> JK> forced, it is common to see this issue no matter what the two link
> JK> partners are.
> I thought the common behavior is that if one side force any particular
> parameter, other side should "sense" that and go to that mode too.
> 
> In current case there is misunderstanding - one side (linux box)
> reports 100/FD and other (switch) reports 100/HD.
> 
> Maybe I don't understand something...
> 

Jeff it correct, but the behavior can change depending on the switch
hardware.  The results you see are expected since I'm quite sure the
IEEE standard says that a device should default to half-duplex when
auto-negotiation fails (which is why your 3com switch defaults to
half-duplex).

-andy

