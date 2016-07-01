From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 00/13] Mellanox 100G mlx5 resiliency and xmit path
 fixes
Date: Fri, 01 Jul 2016 06:14:49 -0400 (EDT)
Message-ID: <20160701.061449.151195686797738506.davem@davemloft.net>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbcGAKXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 06:23:13 -0400
In-Reply-To: <1467297290-11443-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Thu, 30 Jun 2016 17:34:37 +0300

> This series provides two set of fixes to the mlx5 driver:
> 	- Resiliency fixes for reset flow and internal pci errors
> 	- xmit path fixes

Series applied to 'net' but expecting all of this to be backported
to -stable is unreasonable.

PCI error paths, chip resets, timeout handling, etc. and some
non-trivial changes.  This is not appropriate for -stable at all.

What's relevant for -stable is operational bug fixes for issues
users will hit in regular operation.

And yes this is partially my own interpreation of what is appropriate
for -stable.

But if I were to set the precendence of adding all of these to -stable
it means people will then be able to request similar things in other
drivers.  We want to avoid having too much grey area stuff backported
to -stable, there are too many changes going through -stable already.
