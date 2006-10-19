From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: BCM5461 phy issue in 10M/Full duplex
Date: Thu, 19 Oct 2006 17:50:13 +0100 (BST)
Message-ID: <Pine.LNX.4.64N.0610191741390.5982@blysk.ds.pg.gda.pl>
References: <BD5AE82A-22F1-4813-A350-42532AB9A920@kernel.crashing.org>
 <45365C25.9070601@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pollux.ds.pg.gda.pl ([153.19.208.7]:55314 "EHLO
	pollux.ds.pg.gda.pl") by vger.kernel.org with ESMTP
	id S1946221AbWJSQuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 12:50:14 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <45365C25.9070601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Oct 2006, Rick Jones wrote:

> > I believe, but need to double check, that if I leave the BCM5461 in
> > autoneg, and foce the switch to 10M/full that the BCM5461 will  autoneg at
> > 10M/half duplex.
> 
> Indeed, if one side is hardcoded, autoneg will "fail" and the side trying to
> autoneg is required by the specs (not that I know chapter and verse to quote
> from the IEE stuff :( to go into half-duplex.

 Rather than forcing a PHY into 10Mbps, you may limit its advertised list 
of speeds/duplex settings and let autonegotiation do the rest.  It depends 
on how smart code to manage your switch is; it's certainly doable with 
Linux (you can do it with `mii-tool'; not sure about `ethtool') as long as 
the NIC driver supports the necessary ioctls.

> Was 10M/Fullduplex ever standardized?  If not I could see where kit might not
> be willing/able to autoneg to that.

 It is standard.

  Maciej
