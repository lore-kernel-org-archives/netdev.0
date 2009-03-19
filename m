From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH -- take 2] igb: allow tx of pre-formatted vlan
 tagged packets
Date: Wed, 18 Mar 2009 23:40:47 -0700 (PDT)
Message-ID: <20090318.234047.29760524.davem@davemloft.net>
References: <20090312213345.GA12653@ajones-laptop.nbttech.com>
	<20090317173924.GA13723@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	alexander.h.duyck@intel.com
To: ajones@riverbed.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59116
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752564AbZCSGlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 02:41:00 -0400
In-Reply-To: <20090317173924.GA13723@ajones-laptop.nbttech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arthur Jones <ajones@riverbed.com>
Date: Tue, 17 Mar 2009 10:39:24 -0700

> When the 82575 is fed 802.1q packets, it chokes with
> an error of the form:
> 
> igb 0000:08:00.1: partial checksum but proto=81
> 
> As the logic there was not smart enough to look into
> the vlan header to pick out the encapsulated protocol.
> 
> There are times when we'd like to send these packets
> out without having to configure a vlan on the interface.
> Here we check for the vlan tag and allow the packet to
> go out with the correct hardware checksum.
> 
> Thanks to Kand Ly <kand@riverbed.com> for discovering the
> issue and the coming up with a solution.  This patch is
> based upon his work.
> 
> Fixups from Stephen Hemminger <shemminger@vyatta.com> and
> Alexander Duyck <alexander.h.duyck@intel.com>.
> 
> Signed-off-by: Arthur Jones <ajones@riverbed.com>

Jeff, are you queueing this one up?
