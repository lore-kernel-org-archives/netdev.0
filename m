From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ixgbe: fix ixgbe_check_reset_blocked()
 declaration
Date: Mon, 10 Mar 2014 16:28:20 -0400 (EDT)
Message-ID: <20140310.162820.532220881575176361.davem@davemloft.net>
References: <1394414342-2482-1-git-send-email-sakiwit@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aaron.f.brown@intel.com, netdev@vger.kernel.org,
	donald.c.skidmore@intel.com, jeffrey.t.kirsher@intel.com
To: sakiwit@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47194 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbaCJU2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:28:22 -0400
In-Reply-To: <1394414342-2482-1-git-send-email-sakiwit@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>
Date: Sun,  9 Mar 2014 19:19:02 -0600

> The commit c97506ab0e22 ("ixgbe: Add check for FW veto bit")
> introduced the new function ixgbe_check_reset_blocked() with a minor
> issue in declaration. Fix the declaration by changing the type
> specifier to bool as the definition returns a boolean value.
> Additionally all ixgbe_check_reset_blocked() callers are expected to
> return a boolean value.
> 
> Signed-off-by: Jean Sacren <sakiwit@gmail.com>
> Cc: Don Skidmore <donald.c.skidmore@intel.com>

I assume Jeff will pick this up into his Intel tree.
