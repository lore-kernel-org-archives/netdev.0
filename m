From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 1/2] !CONFIG_NET_ETHERNET unsets CONFIG_PHYLIB, but  CONFIG_USB_USBNET also needs CONFIG_PHYLIB
Date: Wed, 25 Oct 2006 22:24:27 -0700
Message-ID: <200610252224.28300.david-b@pacbell.net>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org> <200610251924.04321.david-b@pacbell.net> <45404237.3070307@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: toralf.foerster@gmx.de, netdev@vger.kernel.org,
	linux-usb-devel@lists.sourceforge.net, link@miggy.org,
	greg@kroah.com, akpm@osdl.org, zippel@linux-m68k.org,
	torvalds@osdl.org, linux-kernel@vger.kernel.org,
	dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp109.sbc.mail.mud.yahoo.com ([68.142.198.208]:52355 "HELO
	smtp109.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1423406AbWJZFYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 01:24:32 -0400
To: "Randy.Dunlap" <randy.dunlap@oracle.com>
In-Reply-To: <45404237.3070307@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 25 October 2006 10:05 pm, Randy.Dunlap wrote:

> > 
> > ... MII should still depend on ETHERNET, right?
> > Just not limited to 10/100 Ethernet.
> 
> There is no such config symbol.  NET_ETHERNET means 10/100 ethernet.
> Gigabit ethernet doesn't use the ETHERNET symbol (and doesn't use
> this flavor of MII IIRC).

Ah, you're right -- sorry.  Only Kconfig and net/ipv4/arp.c even
look for that config symbol.

- Dave

