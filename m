From: maowenan <maowenan@huawei.com>
Subject: RE: [PATCH] net: add one ethtool option to set relax ordering mode
Date: Thu, 22 Dec 2016 00:10:00 +0000
Message-ID: <F95AC9340317A84688A5F0DF0246F3F20151F10A@szxeml504-mbs.china.huawei.com>
References: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
 <20161208141153.GI26852@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: maowenan <maowenan@huawei.com>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:4513 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761421AbcLVAKn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 19:10:43 -0500
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> -----Original Message-----
> From: maowenan
> Sent: Monday, December 12, 2016 4:29 PM
> To: 'Andrew Lunn'
> Cc: netdev@vger.kernel.org; jeffrey.t.kirsher@intel.com; weiyongjun (A)
> Subject: RE: [PATCH] net: add one ethtool option to set relax ordering mode
> 
> 
> 
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org
> > [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of Andrew Lunn
> > Sent: Thursday, December 08, 2016 10:12 PM
> > To: maowenan
> > Cc: netdev@vger.kernel.org; jeffrey.t.kirsher@intel.com
> > Subject: Re: [PATCH] net: add one ethtool option to set relax ordering
> > mode
> >
> > On Thu, Dec 08, 2016 at 02:51:37PM +0800, Mao Wenan wrote:
> > > This patch provides one way to set/unset IXGBE NIC TX and RX relax
> > > ordering mode, which can be set by ethtool.
> > > Relax ordering is one mode of 82599 NIC, to enable this mode can
> > > enhance the performance for some cpu architecure.
> > > example:
> > > ethtool -s enp1s0f0 relaxorder off
> > > ethtool -s enp1s0f0 relaxorder on
> >
> > Since this is a simple on/off, could it not be done with a feature?
> > ethtool --feature?
> >
> > 	Andrew
> 
> Hello Andrew,
> 	Thank you for your comments.
> 	I get your idea about using ethtool -K|--feature is good for this feature,
> right?
> My original concert is about this is a relax ordering mode exist in 82599, it is
> the hardware related feature. And ethtool -s option is related hardware of phy
> and other (e.g: speed, duplex...), it is very easy to implement in do_sset().
> But ethtool -K is mainly used for protocol offload,
>         ethtool -K|--features|--offload DEVNAME Set protocol offload and
> other features
>                 FEATURE on|off ...
> @Jeff Kirsher, what's your comments?

@Jeff Kirsher and @David Miller, do you have any other comments about this patch which wants to add ethtool option to on|off relax ordering with 82599?  Thank you.
Here Andrew have comment about using -K or --features on|off relax ordering.







 
