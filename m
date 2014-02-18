From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: Remove inactive code snippet in
 ethtool_set_rxfh_indir
Date: Tue, 18 Feb 2014 17:26:06 -0500 (EST)
Message-ID: <20140218.172606.963581484037616089.davem@davemloft.net>
References: <BF3270C86E8B1349A26C34E4EC1C44CB2C87A575@CMEXMB1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36579 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbaBRW0I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 17:26:08 -0500
In-Reply-To: <BF3270C86E8B1349A26C34E4EC1C44CB2C87A575@CMEXMB1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Date: Tue, 18 Feb 2014 07:38:28 +0000

> ethtool_rxfh_indir_default is invoked inside ethtool_get_rxfh_indir when user_size is zero. However user_size can only be zero when dev_size is zero in which case ethtool_get_rxfh_indir itself would have returned -EOPNOTSUPP error. User_size = 0 can never occur unless a buggy ethtool sends user_size as zero beforing invoking the ioctl in which case we should return -EINVAL.

Please properly format your commit message, with newlines every ~80 columns.

> Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>

Also your patch was corrupted in transit, look at what happened when it hit
patchwork:

	http://patchwork.ozlabs.org/patch/321313/
