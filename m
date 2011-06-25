From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 20:22:05 +0200
Message-ID: <201106252022.05402.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <201106251859.38963.arnd@arndb.de> <1309025217.2454.89.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sriram <srk@ti.com>, Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Anant Gole <anantgole@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:59995 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656Ab1FYSWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 14:22:33 -0400
In-Reply-To: <1309025217.2454.89.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Jeff Kirsher wrote:
>   On Sat, 2011-06-25 at 09:59 -0700, Arnd Bergmann wrote:
> > > More interestingly, if you have one of the 8390 clones, which
> > directory
> > > do you look in?  And shouldn't etherh.c live along side 8390's files
> > > as etherh is 8390-derived?
> > 
> > Jeff created a drivers/net/ethernet/8390/ directory for all of those,
> > which sounds sensible to me, but apparently he missed some of the
> > nonobvious ones. 
> 
> I was trying to keep the drivers that use the 8390 common files grouped
> together.
> 
> I know that there are other instances like this (for instance drivers
> derived from the lance.c driver) yet these derived drivers do not use
> the common files that other lance drivers use.  Because they are
> derived, yet do not use the common code, should they still be grouped
> together?  Just a question, I am fine with the idea.

Generally, I'd say yes, but it's not a strong preference.

In other subsystems, we group similar stuff together like that as well,
as a reminder that it should better use the common infrastructure, so
that someone copying the odd implementation has a better chance of
noticing the mistake early.

	Arnd
