From: David Miller <davem@davemloft.net>
Subject: Re: Use of 'SIOCDEVPRIVATE' in ethernet drivers.
Date: Tue, 07 Jan 2014 14:05:20 -0500 (EST)
Message-ID: <20140107.140520.1985936966889106257.davem@davemloft.net>
References: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: giri.reddy@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750851AbaAGTFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 14:05:23 -0500
In-Reply-To: <124064C45E1FC84193A69A61ED3A1F46E22D07@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giri Reddy <giri.reddy@qlogic.com>
Date: Tue, 7 Jan 2014 18:21:17 +0000

> Are we still allowed to use 'SIOCDEVPRIVATE' in drivers if there the
> deprecation efforts are on hold.

To say that use of SIOCDEVPRIVATE is discouraged would be an
understatement.

Please create a generic ethtool based facility that other drivers in
similar situations can use as well.
