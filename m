From: Joshua Kinard <kumba@gentoo.org>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Tue, 27 Dec 2011 17:48:32 -0500
Message-ID: <4EFA4B40.8090502@gentoo.org>
References: <4EED3A3D.9080503@gentoo.org> <4EF95247.7000403@gentoo.org> <20111227103408.01aad10e@nehalam.linuxnetplumber.net> <4EFA38D5.1000602@gentoo.org> <20111227143441.30d2c42f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, Linux MIPS List <linux-mips@linux-mips.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:38114
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752083Ab1L0Wsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 17:48:54 -0500
In-Reply-To: <20111227143441.30d2c42f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/27/2011 17:34, Stephen Hemminger wrote:

> On Tue, 27 Dec 2011 16:29:57 -0500
> Joshua Kinard <kumba@gentoo.org> wrote:
> 
>> MIPS I/O registers are always memory-mapped, and to prevent the compiler
>> from trying to over-optimize, volatile is used to make sure we always read a
>> value from the hardware and not from some cached value.
> 
> Almost every other network driver had memory mapped register.
> The problem is volatile is that the compiler is stupid and wrong.
> Using explicit barriers is preferred and ensures correct and fast
> code.


I am somewhat new to driver development, so I do not know all the tricks of
the trade just yet.  Do you have references to doing explicit barriers that
I can look at?  Might be worth trying on the RTC driver I have to get the
hang of them.

-- 
Joshua Kinard
Gentoo/MIPS
kumba@gentoo.org
4096R/D25D95E3 2011-03-28

"The past tempts us, the present confuses us, the future frightens us.  And
our lives slip away, moment by moment, lost in that vast, terrible in-between."

--Emperor Turhan, Centauri Republic
