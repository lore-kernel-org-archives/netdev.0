From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [PATCH] ieee80211: Provide generic get_stats implementation
Date: Wed, 22 Nov 2006 12:44:44 +0800
Message-ID: <1164170685.2924.46.camel@debian.sh.intel.com>
References: <20061122031546.4C1767B40A0@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, mb@bu3sch.de,
	ipw2100-admin@linux.intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41052 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1031231AbWKVEry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Nov 2006 23:47:54 -0500
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <20061122031546.4C1767B40A0@zog.reactivated.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-22 at 03:15 +0000, Daniel Drake wrote:
> bcm43xx and ipw2100 currently duplicate the same simplistic get_stats
> handler.
> Additionally, zd1211rw requires the same handler to fix a bug where
> all stats
> are reported as 0.
> 
> This patch adds a generic implementation to the ieee80211 layer, which
> drivers
> are free to override. 

ACK. Looks good to me.

Thanks,
-yi
