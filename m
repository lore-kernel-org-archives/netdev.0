From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [PATCH] vxge: should include tcp.h
Date: Fri, 3 Apr 2009 13:43:28 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77051BF551@nekter>
References: <a4423d670904030234l3734ad45t49009e8ede2e1d2d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Alexander Beregalov" <a.beregalov@gmail.com>,
	<linux-next@vger.kernel.org>, "Netdev" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:6382 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935543AbZDCRne convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 13:43:34 -0400
Content-class: urn:content-classes:message
In-Reply-To: <a4423d670904030234l3734ad45t49009e8ede2e1d2d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please accept. We had CONFIG_IPV6 enabled and so did not see this error.

Thanks,
Ram
> -----Original Message-----
> From: Alexander Beregalov [mailto:a.beregalov@gmail.com]
> Sent: Friday, April 03, 2009 2:35 AM
> To: linux-next@vger.kernel.org; Netdev; David Miller; Ramkrishna Vepa
> Subject: [PATCH] vxge: should include tcp.h
> 
> Fix this build error:
> 
> drivers/net/vxge/vxge-main.c: In function 'vxge_get_vpath_no':
> drivers/net/vxge/vxge-main.c:695: error: dereferencing pointer to
> incomplete type
> ...
> 
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---
> 
>  drivers/net/vxge/vxge-main.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/vxge/vxge-main.c
b/drivers/net/vxge/vxge-main.c
> index 61ef161..b7f08f3 100644
> --- a/drivers/net/vxge/vxge-main.c
> +++ b/drivers/net/vxge/vxge-main.c
> @@ -43,6 +43,7 @@
> 
>  #include <linux/if_vlan.h>
>  #include <linux/pci.h>
> +#include <linux/tcp.h>
>  #include <net/ip.h>
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
