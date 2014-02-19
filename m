From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] ethtool: Remove inactive code snippet in
 ethtool_set_rxfh_indir
Date: Wed, 19 Feb 2014 16:42:43 -0500 (EST)
Message-ID: <20140219.164243.2046477353509124098.davem@davemloft.net>
References: <d966666f-7494-449a-a48f-728f77614738@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: VenkatKumar.Duvvuru@Emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbaBSVmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 16:42:45 -0500
In-Reply-To: <d966666f-7494-449a-a48f-728f77614738@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Date: Wed, 19 Feb 2014 13:20:25 +0530

> ethtool_rxfh_indir_default is invoked inside ethtool_set_rxfh_indir when
> user_size is zero. However user_size can only be zero when dev_size is
> zero in which case ethtool_get_rxfh_indir itself would return
> EOPNOTSUPP error. "user_size = 0" can never happen unless userspace
> ethtool sends user_size as zero beforing invoking the ioctl for
> ETHTOOL_SRSSH, in which case we should return -EINVAL.
> 
> v2: Modified commit message.
> 
> Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>

It looks like the author of this code intended user_size == 0 as a way
to reset the indirection table to the default, did this ever work?
