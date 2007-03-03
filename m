From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] mv643xx_eth: move mac_addr inside mv643xx_eth_platform_data
Date: Fri, 02 Mar 2007 20:17:16 -0500
Message-ID: <45E8CC9C.3080607@pobox.com>
References: <20070301233148.GA19550@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mips@linux-mips.org, Ralf Baechle <ralf@linux-mips.org>
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55539 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992861AbXCCBRT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:17:19 -0500
In-Reply-To: <20070301233148.GA19550@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> The information contained within platform_data should be self-contained.
> Replace the pointer to a MAC address with the actual MAC address in
> struct mv643xx_eth_platform_data.
> 
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> 
> ---
> 
> Replaced explicit mac address comparison with a call to is_valid_ether_addr(),
> as suggested by Stephen Hemminger <shemminger@linux-foundation.org>.
> 
>  arch/mips/momentum/jaguar_atx/platform.c |   20 ++++----------------
>  arch/mips/momentum/ocelot_3/platform.c   |   20 ++++----------------
>  arch/mips/momentum/ocelot_c/platform.c   |   12 ++----------
>  drivers/net/mv643xx_eth.c                |    2 +-
>  include/linux/mv643xx.h                  |    2 +-
>  5 files changed, 12 insertions(+), 44 deletions(-)

applied


