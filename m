From: Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>
Subject: RE: [PATCH v2 net-next] ethtool: Remove inactive code snippet in
 ethtool_set_rxfh_indir
Date: Fri, 21 Feb 2014 10:28:24 +0000
Message-ID: <BF3270C86E8B1349A26C34E4EC1C44CB2C87E699@CMEXMB1.ad.emulex.com>
References: <d966666f-7494-449a-a48f-728f77614738@CMEXHTCAS2.ad.emulex.com>
 <20140219.164243.2046477353509124098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:17592 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaBUK20 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 05:28:26 -0500
In-Reply-To: <20140219.164243.2046477353509124098.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
> Date: Wed, 19 Feb 2014 13:20:25 +0530
> 
> > ethtool_rxfh_indir_default is invoked inside ethtool_set_rxfh_indir
> > when user_size is zero. However user_size can only be zero when
> > dev_size is zero in which case ethtool_get_rxfh_indir itself would
> > return EOPNOTSUPP error. "user_size = 0" can never happen unless
> > userspace ethtool sends user_size as zero beforing invoking the ioctl
> > for ETHTOOL_SRSSH, in which case we should return -EINVAL.
> >
> > v2: Modified commit message.
> >
> > Signed-off-by: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
> 
> It looks like the author of this code intended user_size == 0 as a way to reset
> the indirection table to the default, did this ever work?

There is no option for --set-rxfh-indir to reset the indirection table. So ethtool cannot know that it has to fill user_size = 0 to reset the indirection table to default.
