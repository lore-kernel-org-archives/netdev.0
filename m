From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net/ethtool, mlx4_en: RSS hash function
 setting fixes
Date: Sun, 26 Apr 2015 23:02:08 -0400 (EDT)
Message-ID: <20150426.230208.609174325391847955.davem@davemloft.net>
References: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, talal@mellanox.com,
	ben@decadent.org.uk
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521AbbD0DCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Apr 2015 23:02:10 -0400
In-Reply-To: <1430058966-24046-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Sun, 26 Apr 2015 17:36:04 +0300

> Hash function is represented as an eight bit field, every bit represents a
> function.  Currently possible values are: 1 for Toeplitz and 2 for XOR.
> This commit changes the representation from bit flags into a value. Because
> only one hash function will be used at a time, there is no sense using bit
> flags for it.

If we ever want to add some kind of control attributes that might
apply to any hash, we'll want flags again.

You can just enforce that only one of these hash function bits can be
set at one time, and be done with it.
