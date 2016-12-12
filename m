From: maowenan <maowenan@huawei.com>
Subject: RE: [PATCH] net: add one ethtool option to set relax ordering mode
Date: Mon, 12 Dec 2016 08:30:22 +0000
Message-ID: <F95AC9340317A84688A5F0DF0246F3F20151B0CA@szxeml504-mbs.china.huawei.com>
References: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
 <20161208141153.GI26852@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:51358 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbcLLIci (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 03:32:38 -0500
In-Reply-To: <20161208141153.GI26852@lunn.ch>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Andrew Lunn
> Sent: Thursday, December 08, 2016 10:12 PM
> To: maowenan
> Cc: netdev@vger.kernel.org; jeffrey.t.kirsher@intel.com
> Subject: Re: [PATCH] net: add one ethtool option to set relax ordering mode
> 
> On Thu, Dec 08, 2016 at 02:51:37PM +0800, Mao Wenan wrote:
> > This patch provides one way to set/unset IXGBE NIC TX and RX relax
> > ordering mode, which can be set by ethtool.
> > Relax ordering is one mode of 82599 NIC, to enable this mode can
> > enhance the performance for some cpu architecure.
> > example:
> > ethtool -s enp1s0f0 relaxorder off
> > ethtool -s enp1s0f0 relaxorder on
> 
> Since this is a simple on/off, could it not be done with a feature?
> ethtool --feature?
> 
> 	Andrew

Hello Andrew, 
	Thank you for your comments.
	I get your idea about using ethtool -K|--feature is good for this feature, right? 
My original concert is about this is a relax ordering mode exist in 82599, it is the hardware 
related feature. And ethtool -s option is related hardware of phy and other (e.g: speed, duplex...),
it is very easy to implement in do_sset().
But ethtool -K is mainly used for protocol offload,
        ethtool -K|--features|--offload DEVNAME Set protocol offload and other features
                FEATURE on|off ... 
@Jeff Kirsher, what's your comments?
