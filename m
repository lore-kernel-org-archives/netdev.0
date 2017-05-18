From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] e1000e: Don't return uninitialized stats
Date: Thu, 18 May 2017 10:46:14 -0400 (EDT)
Message-ID: <20170518.104614.1739169308591707817.davem@davemloft.net>
References: <20170425175433.ykc6ilm6uo7e6my2@f1.synalogic.ca>
        <20170517202413.18321-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, s.priebe@profihost.ag,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        pmenzel@molgen.mpg.de, sasha.neftin@intel.com,
        aaron.f.brown@intel.com, stephen@networkplumber.org
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43672 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756532AbdEROqW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:46:22 -0400
In-Reply-To: <20170517202413.18321-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Wed, 17 May 2017 16:24:13 -0400

> Some statistics passed to ethtool are garbage because e1000e_get_stats64()
> doesn't write them, for example: tx_heartbeat_errors. This leaks kernel
> memory to userspace and confuses users.
> 
> Do like ixgbe and use dev_get_stats() which first zeroes out
> rtnl_link_stats64.
> 
> Fixes: 5944701df90d ("net: remove useless memset's in drivers get_stats64")
> Reported-by: Stefan Priebe <s.priebe@profihost.ag>
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Jeff, please be sure to pick this up, thanks.
