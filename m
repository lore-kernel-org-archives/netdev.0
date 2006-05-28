From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: e1000 poor network performance - 2.6.17-rc5-g705af309
Date: Sun, 28 May 2006 09:04:09 -0700
Message-ID: <20060528090409.08a9bce8@localhost.localdomain>
References: <20060526212243.GA19250@SDF.LONESTAR.ORG>
	<4807377b0605271410j39532f44j2cafd3239d40bf31@mail.gmail.com>
	<20060528074310.GA16499@SDF.LONESTAR.ORG>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:62386 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750784AbWE1QEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 May 2006 12:04:21 -0400
To: Aravind Gottipati <aravind@freeshell.org>
In-Reply-To: <20060528074310.GA16499@SDF.LONESTAR.ORG>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 28 May 2006 07:43:10 +0000
Aravind Gottipati <aravind@freeshell.org> wrote:

> On Sat, May 27, 2006 at 02:10:17PM -0700, Jesse Brandeburg wrote:
> > What kind of poor performance?  what test? please send the output of
> > ethtool -e ethX and ethtool -S ethX after you've been having problems.
> 
> I first noticed the problem (slow speed) when pinging sites.  I then
> noticed that the problem occured on normal ssh sessions and ftp/http
> downloads as well.  I have a spare pcmcia card that I am using on the
> same laptop so I have something to compare it against.  In all the
> readings below, eth0 is the builtin Intel 82573L (PCI-Express) card and
> eth2 is a pcmcia D-link card (8139too driver).
> 
> You can see below the ping times varying randomly through eth0.  Compare
> these with the ping times through eth2 (at the bottom).  Also there are
> some collisions in the ethtool -S output here (I am on a 10/100 hub),  I
> see the same performance using a switch as well.
> 
> I am not subscribed to the list, so please cc me on your responses.
> 
> Thank you,
> 
> Aravind.

What is the interrupt assignment on this machine? 
	cat /proc/interrupts

