From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Patchset - Support for configurable RSS hash key
Date: Fri, 17 Jan 2014 19:01:15 -0800 (PST)
Message-ID: <20140117.190115.1213172764234203288.davem@davemloft.net>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8B7@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026AbaARDBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jan 2014 22:01:16 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C83D8B7@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Date: Fri, 17 Jan 2014 13:02:10 +0000

> NIC drivers that support RSS use either a hard-coded value or a random value for the RSS hash key. Irrespective of the type of the key used, the user would want to change the hash key if he/she is not satisfied with the effectiveness of the default hash-key in spreading the incoming flows evenly across the RSS queues.
> 
> This patch set provides support for configuring the RSS hash-key via the ethtool interface.
> 
> The patch set consists of:
> a) ethtool user-land patches
> b) ethtool kernel patch
> c) be2net patch that implements the ethtool hooks

Your submission is confusing.

Changes for the kernel side of things should be submitted as a separate
series, and you do not need to mention where the tree was, via SHA ID,
in the commit message.  It is sufficient to say that your patches are
against the 'net-net' tree, but after the "---" delimiter.  It's not
useful in the commit message proper.
