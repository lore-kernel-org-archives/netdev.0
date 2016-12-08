From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: add one ethtool option to set relax ordering mode
Date: Thu, 8 Dec 2016 15:11:53 +0100
Message-ID: <20161208141153.GI26852@lunn.ch>
References: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: Mao Wenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49161 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751064AbcLHOMA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 09:12:00 -0500
Content-Disposition: inline
In-Reply-To: <1481179898-10668-1-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 02:51:37PM +0800, Mao Wenan wrote:
> This patch provides one way to set/unset IXGBE NIC TX and RX
> relax ordering mode, which can be set by ethtool.
> Relax ordering is one mode of 82599 NIC, to enable this mode
> can enhance the performance for some cpu architecure.
> example:
> ethtool -s enp1s0f0 relaxorder off
> ethtool -s enp1s0f0 relaxorder on

Since this is a simple on/off, could it not be done with a feature?
ethtool --feature?

	Andrew
