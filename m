From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] net: provide common RSS key
 infrastructure
Date: Sun, 16 Nov 2014 16:03:39 -0500 (EST)
Message-ID: <20141116.160339.237379782878143946.davem@davemloft.net>
References: <1416147798-16561-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Thomas.Lendacky@amd.com,
	ariel.elior@qlogic.com, mchan@broadcom.com, prashant@broadcom.com,
	rasesh.mody@qlogic.com, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	amirv@mellanox.com, sshah@solarflare.com, sbhatewara@vmware.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbaKPVDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 16:03:48 -0500
In-Reply-To: <1416147798-16561-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Sun, 16 Nov 2014 06:23:04 -0800

> RSS (Receive Side Scaling) uses a 40 bytes key to provide hash for incoming
> packets to select appropriate incoming queue on NIC.
> 
> Hash algo (Toeplitz) is also well known and documented by Microsoft
> (search for "Verifying the RSS Hash Calculation")
> 
> Problem is that some drivers use a well known key.
> It makes very easy for attackers to target one particular RX queue,
> knowing that number of RX queues is a power of two, or at least some
> small number.
> 
> Other drivers use a random value per port, making difficult
> tuning on bonding setups.
> 
> Lets add a common infrastructure, so that host gets an unique
> RSS key, and drivers do not have to worry about this.

Looks good, series applied, thanks Eric.
