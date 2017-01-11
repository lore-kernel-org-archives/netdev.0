From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: add rcu_read locking to netvsc callback
Date: Tue, 10 Jan 2017 21:06:21 -0500 (EST)
Message-ID: <20170110.210621.1899425596662682692.davem@davemloft.net>
References: <20170110155016.4897-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34540 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753885AbdAKCGW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:06:22 -0500
In-Reply-To: <20170110155016.4897-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 10 Jan 2017 07:50:16 -0800

> Lockdep finds a case where netvsc receive processing is incorrectly
> assuming it is in RCU safe zone. The driver is using RCU to handle
> VF reference but RCU read lock not held.
> 
> Fixes 0c9d3ba9a87b ("hv_netvsc: use RCU to protect vf_netdev")
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Fixes tag must have a colon character after "Fixes", you must also
not put any empty lines in between the Fixes tag and the other
tags like signoffs.

Futhermore 0c9d3ba9a87b is not a valid GIT SHA1 ID.

[davem@kkuri net]$ git describe 0c9d3ba9a87b
fatal: Not a valid object name 0c9d3ba9a87b
