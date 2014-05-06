From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 23/24] net, diet: Add coccinelle script to convert
 drivers to ETHTOOL_OPS
Date: Tue, 06 May 2014 11:05:04 -0400 (EDT)
Message-ID: <20140506.110504.2135392385828482331.davem@davemloft.net>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<1399328773-6531-24-git-send-email-andi@firstfloor.org>
	<CAAxaTiOYTEQgibnpDBXdhNpJUAVrLFwxz0roq8Bin1rNnnsxgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tom.zanussi@linux.intel.com, ak@linux.intel.com,
	Julia.Lawall@lip6.fr, Gilles.Muller@lip6.fr
To: nicolas.palix@imag.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228AbaEFPFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:05:10 -0400
In-Reply-To: <CAAxaTiOYTEQgibnpDBXdhNpJUAVrLFwxz0roq8Bin1rNnnsxgg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Palix <nicolas.palix@imag.fr>
Date: Tue, 6 May 2014 11:27:27 +0200

> I saw you rejected almost the entire patch series.
> 
> However, is there any interest to enforce the use of SET_ETHTOOL_OPS ?
> Are you likely to merge the patch 24/24 [1] ?

SET_ETHTOOL_OPS only exists so that drivers could be compiled
on "older" kernels.

But the usefulness of that is long gone, we've had netdev->ethtool_ops
since way before we started using GIT.

I'd rather see a patch which removes it, to be honest.
