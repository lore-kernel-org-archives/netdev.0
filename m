From: David Miller <davem@davemloft.net>
Subject: macvtap MAX_SKB_FRAGS fix...
Date: Mon, 05 Aug 2013 20:51:04 -0700 (PDT)
Message-ID: <20130805.205104.295403081094571911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab3HFDvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:51:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jason, I want to get that into v3.4.x -stable but it needs a backport
and I'd rather someone like you who knows the code does it rather
than I.

The issue seems that be that the arguments to uarg->callback() were
different back then.

Thanks.
