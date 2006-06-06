From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: NETDEV WATCHDOG: eth2: transmit timed out with 3c905C-TX
Date: Tue, 6 Jun 2006 21:13:26 +0200
Message-ID: <20060606191326.GE14011@bayes.mathematik.tu-chemnitz.de>
References: <20060523205842.GC18008@bayes.mathematik.tu-chemnitz.de> <BAY103-F31CD06F5FF6568FC37AFEAB2950@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:64405 "EHLO
	john.hrz.tu-chemnitz.de") by vger.kernel.org with ESMTP
	id S1750714AbWFFTN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 15:13:28 -0400
To: Marco Berizzi <pupilla@hotmail.com>
Content-Disposition: inline
In-Reply-To: <BAY103-F31CD06F5FF6568FC37AFEAB2950@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 06, 2006 at 11:12:45AM +0200, Marco Berizzi wrote:
> 
> I have moved this damn pc from the remote to my site and I have
> placed it in production environment with 2.6.17-rc5
> No problem after 24 hours (on the remote side the problem was
> arising after a couple of hours). I have modprobed 3c59x with
> debug=4. I see only these kind of messages (are they fine?):
> 
> Jun  5 14:31:25 Pleiadi kernel: eth2: vortex_error(), status=0x8081
> Jun  5 14:31:40 Pleiadi last message repeated 3 times
> Jun  5 14:31:47 Pleiadi kernel: eth2: vortex_error(), status=0x8281
> Jun  5 14:31:47 Pleiadi kernel: eth2: Media selection timer tick happened, 
> Autonegotiate.
> Jun  5 14:31:47 Pleiadi kernel: dev->watchdog_timeo=1250
> Jun  5 14:31:47 Pleiadi kernel: eth2: MII transceiver has status 782d.
> Jun  5 14:31:47 Pleiadi kernel: eth2: Media selection timer finished, 
> Autonegotiate.
> Jun  5 14:31:51 Pleiadi kernel: eth2: vortex_error(), status=0x8081
> Jun  5 14:32:03 Pleiadi last message repeated 2 times
> Jun  5 14:32:10 Pleiadi kernel: eth2: vortex_error(), status=0x8481
> Jun  5 14:32:15 Pleiadi kernel: eth2: vortex_error(), status=0x8081
> Jun  5 14:32:46 Pleiadi last message repeated 7 times

This is ok, just normal operation of the NIC.

> 
> The only relevant change, between the remote and my site, is a
> different ethernet switch where the 3c905C is connected to.
> Could it be an issue?

Well, I think it can. Problems with a switch are mostly related
to the autonegotiation of the media type and full/half-duplex. 
But in your case the autonegotiation seems to be ok 
(mii-tool/ethtool output). More specific information you can
get with the mii-diag and vortex-diag tools. You can find    
these tools at http://www.scyld.com/ethercard_diag.html

There are problems with a cisco switch documented in
Documentation/networking/vortex.txt for example.

Steffen
