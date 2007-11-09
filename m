From: Ben Dooks <ben@fluff.org>
Subject: Re: [RFC] dependencies for platform drivers (was Re: ax88796: add
	superh to kconfig dependencies)
Date: Fri, 9 Nov 2007 12:08:44 +0000
Message-ID: <20071109120844.GB31353@fluff.org.uk>
References: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se> <20071108081854.GN8181@ftp.linux.org.uk> <20071109092652.GA13350@linux-mips.org> <20071109094023.GA7022@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Paul Mundt <lethal@linux-sh.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Al Viro <viro@ftp.linux.org.uk>,
	Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
	ben-linux@fluff.or
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:65512 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754083AbXKIMuC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 07:50:02 -0500
Content-Disposition: inline
In-Reply-To: <20071109094023.GA7022@linux-sh.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 09, 2007 at 06:40:23PM +0900, Paul Mundt wrote:
> On Fri, Nov 09, 2007 at 09:26:52AM +0000, Ralf Baechle wrote:
> > If writesb() is not an official API then maybe the answer should have been
> > to either add that API to other architectures or fix the driver.
> > 
> > I guess this incident means I need to go through all Kconfig* files to
> > see what bogus architecture dependencies on MIPS or !MIPS exist ...
> > 
> While writesb() isn't an official API, the iowriteX_rep() interfaces
> theoretically are. Tidying up the driver for iomap is probably a better
> option.

If anyone else isn't interested in doing this, and there are
no objections to having it done, then I would be willing to
look at moving to the iowrite interfaces.

The only other way would be to add an 8/16bit configuration
to drop the use of writesb, as I belive most people connect
these devices in 16bit mode.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
