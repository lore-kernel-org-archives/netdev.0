From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] New functions to manipulate registers for ethtool
Date: Mon, 08 Dec 2008 01:06:34 -0800 (PST)
Message-ID: <20081208.010634.247305010.davem@davemloft.net>
References: <20081208171230.288c5ccf.mitake@clustcom.com>
	<20081208.005431.200957157.davem@davemloft.net>
	<58622.1228726903@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitake@clustcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ktaka@clustcom.com
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45182
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751369AbYLHJGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 04:06:33 -0500
In-Reply-To: <58622.1228726903@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valdis.Kletnieks@vt.edu
Date: Mon, 08 Dec 2008 04:01:43 -0500

> On Mon, 08 Dec 2008 00:54:31 PST, David Miller said:
> > From: Hitoshi Mitake <mitake@clustcom.com>
> > Date: Mon, 8 Dec 2008 17:12:30 +0900
> > 
> > > I want to add two new functions to ethtool.
> > > 
> > > One is for setting driver's registers on MMIO area like
> > > --change-eeprom option.
> > 
> > You can map the registers into userspace using the bus
> > level mmap facilities exported to userspace.
> > 
> > No ethtool support is necessary for this.
> 
> Yes, but if Hitoshi wants to tell a user "run this command and send me
> the output", what's the incantation the user needs to use?

That's an awful reason to have to two ways of doing the exact same
thing from userspace.

Write the tool.  Someone will if it's important enough (in fact
such code probably exists already).

