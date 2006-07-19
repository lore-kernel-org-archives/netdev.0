From: Patrick McHardy <kaber@trash.net>
Subject: Re: Repost: Re: [VLAN]: translate IF_OPER_DORMANT to netif_dormant_on()
Date: Wed, 19 Jul 2006 14:42:35 +0200
Message-ID: <44BE28BB.8020608@trash.net>
References: <200603211829.k2LITMNR029085@hera.kernel.org> <200607071145.09325.stefan@loplof.de> <44AE2FCC.6020207@trash.net> <200607120015.17735.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63214 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S964806AbWGSMmh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 08:42:37 -0400
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200607120015.17735.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Rompf wrote:
> VLAN devices did not get registered as admin up in 2.6.16 and IMHO also
> not in 2.6.17. So update patch description.
> 
> Ok,
> 
> the following patch should fix the problem. Patrick, can you give it a
> try? As the bug did not affect me through my testing, I want to be sure it
> works now. This is stuff for 2.6.18 and 2.6.17-stable.

Sorry for the delay. Just tested by unplugging the cable from eth0,
adding a bunch of VLANs and plugging the cable again, everything
works fine.

> [VLAN]: Fix link state propagation
> 
> When the queue of the underlying device is stopped at initialization time
> or the device is marked "not present", the state will be propagated to the
> vlan device and never change. Based on an analysis by Patrick McHardy.

ACKed-by: Patrick McHardy <kaber@trash.net>
