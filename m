From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: ethtool TODO list - additional info
Date: Tue, 12 Jul 2016 15:18:28 -0400
Message-ID: <20160712191828.GB22464@tuxdriver.com>
References: <20160712175558.GB1799@nanopsycho.orion>
 <CAPfrtUcAuu5t7xQ-F4d-+AAbSByOzD7aBa_+UsE_xoXRdxEuoA@mail.gmail.com>
 <20160712181251.GA22464@tuxdriver.com>
 <20160712.113406.1402587122290887574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jorge.garcia.gonzalez@gmail.com, jiri@resnulli.us,
	ben@decadent.org.uk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39768 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbcGLTaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 15:30:20 -0400
Content-Disposition: inline
In-Reply-To: <20160712.113406.1402587122290887574.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 11:34:06AM -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Tue, 12 Jul 2016 14:12:52 -0400
> 
> > I haven't heard a strong case for why it is necessary.
> 
> Stats on large scale setups/systems is problematic and ethtool
> is a part of that problem.
> 
> Extensibility in general suffers because of the ioctl() interface as
> well.
> 
> For getting ethtool settings or stats, we have no clean filtering
> mechanism.
> 
> I could go on and on...
> 
> I think before any new features are added to ethtool, we move over to
> the netlink based interface and lock the existing ioctl() API in stone.

OK, then I'll start looking at this. Thanks for providing some clarity!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
