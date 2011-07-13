From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/2] e1000e: use GFP_KERNEL allocations at init time
Date: Tue, 12 Jul 2011 22:08:12 -0700 (PDT)
Message-ID: <20110712.220812.2217115199353001777.davem@davemloft.net>
References: <1310523012-25391-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1310523012-25391-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, eric.dumazet@gmail.com,
	greearb@candelatech.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46983 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab1GMFI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 01:08:26 -0400
In-Reply-To: <1310523012-25391-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 12 Jul 2011 19:10:12 -0700

> In process and sleep allowed context, favor GFP_KERNEL allocations over
> GFP_ATOMIC ones.
> 
> -v2: fixed checkpatch.pl warnings
> 
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Ben Greear <greearb@candelatech.com>
> CC: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>

Applied.
