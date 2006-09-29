From: Andrea Gelmini <gelma@gelma.net>
Subject: Re: sky2 (was Re: 2.6.18-mm2)
Date: Fri, 29 Sep 2006 18:04:13 +0200
Message-ID: <20060929160413.GB4067@gelma.net>
References: <20060928155053.7d8567ae.akpm@osdl.org> <451C5599.80402@garzik.org> <20060928162539.7d565d0a.akpm@osdl.org> <20060928163023.21086528@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>,
	oe@hentges.net, Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aa010msg.fastweb.it ([213.140.2.77]:2510 "EHLO
	aa010msg.fastweb.it") by vger.kernel.org with ESMTP
	id S1161096AbWI2QEo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 12:04:44 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060928163023.21086528@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 28, 2006 at 04:30:23PM -0700, Stephen Hemminger wrote:
> Note: I know what is causing all the sky2 problems, there is something wrong that
> is causing flow control negotiation not to propagate back to all the multiple levels
> of the chip. Unclear how to fix it, the documentation is not helpful on this.
> If not resolved soon, I'll just force Tx flow control off for now.

just for the record, same problem here.
I mean, with my Sony Vaio VGN-SZ1VP (here[1] you can find all hardware
details), it's enough some mega of udp traffic, usually nfs, to "freeze"
the network. Well, no complain from the kernel. It's enough to rmmod and
modprobe sky2 to fix the problem. I already tried -mm1, but nothing
changed. In the meanwhile I will continue to use my usb network card.

Thanks a lot for your time,
Andrea Gelmini

-------
[1] http://groups.google.it/group/linux.kernel/msg/ceff3014c410bea6 
