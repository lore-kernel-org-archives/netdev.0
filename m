From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Permit users to change transmit and receive max
 pachet size
Date: Mon, 03 Aug 2015 14:12:31 -0700 (PDT)
Message-ID: <20150803.141231.997328134552287186.davem@davemloft.net>
References: <yqromneucjufgmy89t6y59jf.1438635988401@email.android.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: corcodel.marian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44869 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358AbbHCVMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 17:12:32 -0400
In-Reply-To: <yqromneucjufgmy89t6y59jf.1438635988401@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Corcodel.marian" <corcodel.marian@gmail.com>
Date: Tue, 04 Aug 2015 00:06:28 +0300

> Sorry bu these parameters is not covered by ethtool.

Then simply add such a generic facility, so other drivers can benefit
from it as well.

I'll be completely honest, and say that I don't anticipate that you
will implement the ethtool option properly, and that it will probably
take 5 or 6 iterations of review of such a patch before we'll be
willing to accept it.  But this is really what you will have to do.

Then you will need to submit a patch to 'ethtool' itself to support
the new options.
