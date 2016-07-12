From: David Miller <davem@davemloft.net>
Subject: Re: ethtool TODO list - additional info
Date: Tue, 12 Jul 2016 11:34:06 -0700 (PDT)
Message-ID: <20160712.113406.1402587122290887574.davem@davemloft.net>
References: <20160712175558.GB1799@nanopsycho.orion>
	<CAPfrtUcAuu5t7xQ-F4d-+AAbSByOzD7aBa_+UsE_xoXRdxEuoA@mail.gmail.com>
	<20160712181251.GA22464@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jorge.garcia.gonzalez@gmail.com, jiri@resnulli.us,
	ben@decadent.org.uk, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcGLSeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:34:08 -0400
In-Reply-To: <20160712181251.GA22464@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 12 Jul 2016 14:12:52 -0400

> I haven't heard a strong case for why it is necessary.

Stats on large scale setups/systems is problematic and ethtool
is a part of that problem.

Extensibility in general suffers because of the ioctl() interface as
well.

For getting ethtool settings or stats, we have no clean filtering
mechanism.

I could go on and on...

I think before any new features are added to ethtool, we move over to
the netlink based interface and lock the existing ioctl() API in stone.
