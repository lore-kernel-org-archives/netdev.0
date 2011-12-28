From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Tue, 27 Dec 2011 16:29:03 -0800
Message-ID: <20111227162903.48c6c619@nehalam.linuxnetplumber.net>
References: <4EED3A3D.9080503@gentoo.org>
	<4EF95247.7000403@gentoo.org>
	<20111227103408.01aad10e@nehalam.linuxnetplumber.net>
	<4EFA38D5.1000602@gentoo.org>
	<20111227143441.30d2c42f@nehalam.linuxnetplumber.net>
	<4EFA4B40.8090502@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux MIPS List <linux-mips@linux-mips.org>
To: Joshua Kinard <kumba@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36556 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607Ab1L1A3H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Dec 2011 19:29:07 -0500
In-Reply-To: <4EFA4B40.8090502@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 27 Dec 2011 17:48:32 -0500
Joshua Kinard <kumba@gentoo.org> wrote:

> On 12/27/2011 17:34, Stephen Hemminger wrote:
> 
> > On Tue, 27 Dec 2011 16:29:57 -0500
> > Joshua Kinard <kumba@gentoo.org> wrote:
> > 
> >> MIPS I/O registers are always memory-mapped, and to prevent the compiler
> >> from trying to over-optimize, volatile is used to make sure we always read a
> >> value from the hardware and not from some cached value.
> > 
> > Almost every other network driver had memory mapped register.
> > The problem is volatile is that the compiler is stupid and wrong.
> > Using explicit barriers is preferred and ensures correct and fast
> > code.
> 
> 
> I am somewhat new to driver development, so I do not know all the tricks of
> the trade just yet.  Do you have references to doing explicit barriers that
> I can look at?  Might be worth trying on the RTC driver I have to get the
> hang of them.
> 

Start by reading volatile considered harmful and memory barriers in kernel
Documentation directory. Paul does a better job of explaining it than
I could ever do :-)
