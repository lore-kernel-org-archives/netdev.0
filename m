From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Display adjacent switch port's attributes
Date: Thu, 12 Dec 2013 12:28:01 -0500 (EST)
Message-ID: <20131212.122801.1249371766101769652.davem@davemloft.net>
References: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com>
	<20131211121357.4742d9e8@nehalam.linuxnetplumber.net>
	<52A9C0BE.5090801@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, bhutchings@solarflare.com,
	blaschka@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: raspl@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914Ab3LLR2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 12:28:04 -0500
In-Reply-To: <52A9C0BE.5090801@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Date: Thu, 12 Dec 2013 14:57:18 +0100

> I agree, netlink would certainly be nice. But ethtool is the
> de-facto standard for now, and there doesn't seem to be a
> netlink-based alternative in sight - or is there?
> Offering a netlink based tool seems to be a different discussion,
> and if that takes shape, existing ethtool functionality (including
> this series) can and should be migrated.

I completely disagree, ethtool is not de-facto for anything in
particular.  It's suitable for some things, not suitable for
others.

And just because it's used for other aspects of a device's
configuration doesn't mean that netlink isn't appropriate for other
apsects.
