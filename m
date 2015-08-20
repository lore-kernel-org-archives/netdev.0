From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] vrf: cleanups part 2
Date: Thu, 20 Aug 2015 13:02:15 -0700 (PDT)
Message-ID: <20150820.130215.85867705258300944.davem@davemloft.net>
References: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com,
	shm@cumulusnetworks.com, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56857 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbbHTUCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 16:02:16 -0400
In-Reply-To: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Wed, 19 Aug 2015 06:27:06 +0300

> This is the next part of vrf cleanups, patch 1 drops the SLAB_PANIC when
> creating kmem cache since it's handled, patch 02 removes a slave duplicate
> check which is already done by the lower/upper code, patch 3 moves the
> ndo_add_slave code around a bit so we can drop an error label and patch 4
> drops the master device checks which are unnecessary because the ops are
> taken from the master device itself so it can't be different.

Series applied, thanks.
