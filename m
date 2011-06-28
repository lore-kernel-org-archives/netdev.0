From: Alan Cox <alan@linux.intel.com>
Subject: Re: [RFC 02/72] 3c*/acenic/typhoon: Move 3Com Ethernet drivers
Date: Tue, 28 Jun 2011 09:22:12 +0100
Message-ID: <20110628092212.37708ca7@bob.linux.org.uk>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1309010363-22750-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Philip Blundell <philb@gnu.org>,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	David Dillow <dave@thedillows.org>,
	Jes Sorensen <jes@trained-monkey.org>,
	Donald Becker <becker@scyld.com>,
	Craig Southeren <craigs@ineluki.apana.org.au>,
	David Hinds <dahinds@users.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4510 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756729Ab1F1IWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 04:22:36 -0400
In-Reply-To: <1309010363-22750-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Jun 2011 06:58:13 -0700
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> Moves the 3Com drivers into drivers/net/ethernet/3com/ and the
> necessary Kconfig and Makefile changes.

This seems a bizarre way to carve stuff up.

To start with several of the things you put in 3com are just branded
items, or are boards using non 3com devices which are currently with
the other drivers that do so, some even use shared midlayers that you
move them away from.

You also pull stuff out of pcmcia which makes it harder to scan stuff
grouped logically.

So this all seems a bit daft to me.

Surely it would make sense to put all the Intel 825xx stuff together,
all the 8390 stuff together and so on.

Alan
