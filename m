From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bridge: multicast: temp and perm entries
 behaviour enhancements
Date: Mon, 20 Jul 2015 12:49:39 -0700 (PDT)
Message-ID: <20150720.124939.1328394717828737521.davem@davemloft.net>
References: <1436969811-13237-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	herbert@gondor.apana.org.au, stephen@networkplumber.org,
	sashok@cumulusnetworks.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756481AbbGTTtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 15:49:40 -0400
In-Reply-To: <1436969811-13237-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Wed, 15 Jul 2015 07:16:49 -0700

> Hi,
> Patch 01 adds a notify when a group is deleted via br_multicast_del_pg()
> (on expire, on device delete or on device down).
> Patch 02 changes how bridge device and bridge port delete and down/up are
> handled. Until now on bridge down all groups were flushed, now only the
> temp ones are (same for port), perm entries are flushed only on port or
> bridge removal.

Series applied, but if patch #2 breaks things for anyone depending upon the
old behavior of flushing all entries I will have to revert.
