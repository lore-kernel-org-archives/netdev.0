From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] openvswitch: maintain correct checksum state in
 conntrack actions
Date: Sun, 15 Jan 2017 22:16:31 -0500 (EST)
Message-ID: <20170115.221631.1432868195915672145.davem@davemloft.net>
References: <1484267598-4493-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56798 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751246AbdAPDQd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 22:16:33 -0500
In-Reply-To: <1484267598-4493-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Thu, 12 Jan 2017 19:33:18 -0500

> When executing conntrack actions on skbuffs with checksum mode
> CHECKSUM_COMPLETE, the checksum must be updated to account for
> header pushes and pulls. Otherwise we get "hw csum failure"
> logs similar to this (ICMP packet received on geneve tunnel
> via ixgbe NIC):
 ...
> Fixes: 7f8a436eaa2c ("openvswitch: Add conntrack action")
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Applied and queued up for -stable.
