From: Olaf Kirch <okir@suse.de>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 22:00:13 +0200
Message-ID: <20060829200012.GA32416@suse.de>
References: <20060829082435.GA2676@suse.de> <20060829181021.GA3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jan Beulich <jbeulich@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:34747 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751332AbWH2UAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:00:14 -0400
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20060829181021.GA3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2006 at 08:10:21PM +0200, Thomas Graf wrote:
> > When the Xen people looked for a way to disable IPv6 autoconf of the
> > bridge, they didn't find any way to do it without bringing up the
> > device first (and thereby triggering DAD).
> 
> They didn't find any because there is no need to disable it. I

Well, as a global statement that may merit a separate debate.
In this specific case, maybe.

First off, I do agree that the use of a constant MAC address across the
board is a bad move :)

OTOH, there are good reasons why you want to turn off autoconf on
specific devices; and the current method of first bringing up
the device and then disabling it doesnt quite cut it.

One could also argue that there's a good reason to not assign addresses
to pure bridge devices at all, regardless of their brokenness.
We don't want to assign IPv4 addresses to a pure bridge, and I think it's
a reasonable expectation that there should be a way to tell the IPv6
stack to keep its hands off that device, too.

> got wrong. Setting dev_addr to -1 is just plain wrong, other
> virtual ethernet devices call random_ether_addr(), it's not a
> new problem at all.

Okay, fine with me - maybe we can convince them to use that
instead.

Thanks for the feedback,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
