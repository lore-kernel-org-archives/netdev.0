From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ps3: gigabit ethernet driver for PS3, take3
Date: Tue, 10 Jul 2007 14:14:47 -0400
Message-ID: <4693CC97.4030207@garzik.org>
References: <20070705193748.D018.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32944 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755160AbXGJSOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 14:14:52 -0400
In-Reply-To: <20070705193748.D018.MOKUNO@sm.sony.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Masakazu Mokuno wrote:
> Hi, 
> 
> This is the third submission of the network driver for PS3.
> The differences from the previous one are:
> 
>   - renamed source file names so that their prefix can match
>     with the module name
>   - added cbe-oss-dev@ozlabs.org line for MAINTAINER file
>   - changed some in copyright comments
>   
> If there are no more comments, please apply for 2.6.23. 
> 
> Thank you
> 
> --
> Subject: PS3: Ethernet driver
> 
> From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> 
> Add Gigabit Ethernet support for the PS3 game console.  The module will
> be called ps3_gelic.
> 
> CC: Geoff Levand <geoffrey.levand@am.sony.com>
> Signed-off-by: Masakazu Mokuno <mokuno@sm.sony.co.jp>
> ---
>  MAINTAINERS                 |    7 
>  drivers/net/Kconfig         |   10 
>  drivers/net/Makefile        |    2 
>  drivers/net/ps3_gelic_net.c | 1576 ++++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/ps3_gelic_net.h |  239 ++++++
>  5 files changed, 1834 insertions(+)

applied

I request that you fix the NETDEV_TX_LOCKED return value on error in 
->hard_start_xmit(), which appears to be an incorrect return value for 
that condition, for your driver

	Jeff



