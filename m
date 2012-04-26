From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5][6lowpan] several fixes for 6lowpan
Date: Wed, 25 Apr 2012 20:35:54 -0400 (EDT)
Message-ID: <20120425.203554.1187346578559639487.davem@davemloft.net>
References: <1335264671-27127-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932686Ab2DZAgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 20:36:07 -0400
In-Reply-To: <1335264671-27127-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Tue, 24 Apr 2012 14:51:06 +0400

> the following patch-set contains several fixes/improvements for 6lowpan:
> 1. fix: segmentation fault caused by mlme request
> 2. impr: move frame allocation code to a separate function
> 3. fix: clean up fragments list if module unloaded
> 4. impr: duplicate definition of IEEE802154_ALEN
> 5. fix: add missing spin_lock_init()
> 
> Could you please review them?

You need to not mix bug fixe patches with one which perform
cleanups and code refactoring.

Submit the pure bug fixes as one set, against the 'net' tree.

Then submit the rest as another set, against the 'net-next' tree.

Thanks.
