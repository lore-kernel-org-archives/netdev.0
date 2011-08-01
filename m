From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 02/71] 3c*/acenic/typhoon: Move 3Com Ethernet
 drivers
Date: Mon, 01 Aug 2011 02:21:07 -0700 (PDT)
Message-ID: <20110801.022107.740149515523315115.davem@davemloft.net>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1312082850-24914-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110801100303.48ed75f7@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, philb@gnu.org,
	klassert@mathematik.tu-chemnitz.de, dave@thedillows.org,
	jes@trained-monkey.org, becker@scyld.com,
	craigs@ineluki.apana.org.au, dahinds@users.sourceforge.net
To: alan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab1HAJXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 05:23:07 -0400
In-Reply-To: <20110801100303.48ed75f7@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>
Date: Mon, 1 Aug 2011 10:03:03 +0100

> And even if you wanted to make Kconfig simpler - you don't need to move
> files around.

The point is to move the files around, so that drivers/net/ isn't
a turd pond.

I agree with some of your feedback, but I disagree with a wholesale
rejecting the idea of untangling the mess under drivers/net/ as that's
the main reason why I want Jeff's work to be done
