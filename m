From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/7] net: ipmr: more cleanups and mfc netlink
 support
Date: Thu, 26 Nov 2015 17:35:02 +0100
Message-ID: <20151126163502.GB4094@lunn.ch>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42492 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752633AbbKZQfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Nov 2015 11:35:04 -0500
Content-Disposition: inline
In-Reply-To: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 26, 2015 at 03:23:43PM +0100, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Hi,
> This set continues with the minor cleanups in the first 6 patches and
> patch 7 adds the first new feature - MFC manipulation via netlink.

Hi Nikolay

Great to see somebody working on multicast.

Do you have any plans to remove the 32 VIF limit?

I've run out if VIFs on a VPN server with lots of clients. I took the
"quick fix" of recompiling the kernel and userspace with 256 VIFs. But
it would be nice if you could define a netlink API which does not have
this limit and modify the core code to be more dynamic.

     Andrew
