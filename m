From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0 of 2] implement tty driver for netconsole
Date: Sat, 29 Nov 2008 21:39:47 -0800 (PST)
Message-ID: <20081129.213947.185052916.davem@davemloft.net>
References: <patchbomb.1227820260@localhost.localdomain>
	<1227827385.3196.49.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hollisb@us.ibm.com, netdev@vger.kernel.org
To: mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45323
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751203AbYK3Fjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 00:39:47 -0500
In-Reply-To: <1227827385.3196.49.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Mackall <mpm@selenic.com>
Date: Thu, 27 Nov 2008 17:09:45 -0600

> On Thu, 2008-11-27 at 15:11 -0600, Hollis Blanchard wrote:
> > I have a Kuro Box (a small NAS device running Linux), and it has no serial
> > console (nor any other console for that matter). The most convenient way to get
> > boot output is via the netconsole driver, which is what most Kuro owners do. (The u-boot
> > firmware even supports interactive netconsole allowing us to edit boot configuration.)
> > 
> > However, once past kernel boot, userspace currently has no way of outputting data over
> > netconsole. These patches enable that, which is really useful for seeing init
> > script output and debugging ramdisks before they've brought up sshd.
> 
> Awesome! I've been meaning to wire this up for ages. I'll try to look at
> it over the weekend.

Matt if your review goes OK please ACK this and I'll toss these
patches into net-next-2.6

Thanks
