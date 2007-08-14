From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 15/18] drivers/net: remove superfluous memset
Date: Tue, 14 Aug 2007 01:38:11 -0400
Message-ID: <46C13FC3.2020706@garzik.org>
References: <200708102105.l7AL5PRA008989@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, m.kozlowski@tuxland.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44543 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934359AbXHNFiN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 01:38:13 -0400
In-Reply-To: <200708102105.l7AL5PRA008989@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> 
> 	This patch covers something like this:
> 
> dev = alloc_*dev(...
> ...
> priv = netdev_priv(dev);
> memset(priv, 0, sizeof(*priv));
> 
> The memset() here is superfluous. alloc_netdev() uses kzalloc()
> to allocate needed memory so there is no need to zero the priv region
> twice.
> 
> Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/fs_enet/fs_enet-main.c   |    1 -
>  drivers/net/myri10ge/myri10ge.c      |    1 -
>  drivers/net/netxen/netxen_nic_main.c |    1 -
>  drivers/net/sunlance.c               |    1 -
>  drivers/net/usb/pegasus.c            |    1 -
>  drivers/net/usb/rtl8150.c            |    1 -
>  6 files changed, 6 deletions(-)

applied


