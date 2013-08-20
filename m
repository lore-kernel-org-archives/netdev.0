From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 0/6] 6lowpan: address uncompression fixes
Date: Tue, 20 Aug 2013 13:24:22 -0700 (PDT)
Message-ID: <20130820.132422.1578029760023546117.davem@davemloft.net>
References: <1376683199-10370-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: alex.aring@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751157Ab3HTUYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 16:24:24 -0400
In-Reply-To: <1376683199-10370-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Aring <alex.aring@gmail.com>
Date: Fri, 16 Aug 2013 21:59:53 +0200

> The current implementation to uncompress addresses in a 6lowpan header
> is completely broken.
> 
> This patch series fixes the parsing of addresses in a 6lowpan header.
> It contains a major rewrite of the uncompress address function to parse
> the address in a correct way.
> 
> Tested with the ravenusbstick(contiki 6LoWPAN stack) and beaglebone
> (linux 6LoWPAN Stack) on the other side. The linux side contains all
> possible addresses for the uncompression cases. Then I type a ping6 for
> each case and lookup in wireshark and dmesg the correct reconstruction.

Series applied to net-next, thanks.
