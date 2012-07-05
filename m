From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 6lowpan: revert 'reuse eth_mac_addr()'
Date: Thu, 05 Jul 2012 03:13:51 -0700 (PDT)
Message-ID: <20120705.031351.63082130704857819.davem@davemloft.net>
References: <1341208726-2793-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, danny.kukawka@bisect.de,
	dbaryshkov@gmail.com
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755428Ab2GEKNw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 06:13:52 -0400
In-Reply-To: <1341208726-2793-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Mon,  2 Jul 2012 09:58:46 +0400

> This reverts the commit cdf49c283e2e105da86ca575ad35b453f5ff24ea which
> replaces lowpan '.ndo_set_mac_address' method by ethernet's one.
> 
> Accorind to the IEEE 802.15.4 standard, device has 8-byte length address,
> so this hook loses the last 2 bytes which may rise a compatibility problems
> with other IEEE 802.15.4 standard implementations.
> 
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Applied.
