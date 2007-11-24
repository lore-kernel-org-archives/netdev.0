From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.24 1/2]S2io: Strip the vlan tag if the vlan group
 is	not NULL
Date: Fri, 23 Nov 2007 22:04:28 -0500
Message-ID: <474794BC.5030709@garzik.org>
References: <1195509636.1995.39.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, support@neterion.com
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39637 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753607AbXKXDE3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 22:04:29 -0500
In-Reply-To: <1195509636.1995.39.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ramkrishna Vepa wrote:
> - Updated the vlan tag stripping code as per Dave Johnson's patch
>   <djohnson@sw.starentnetworks.com>
>   Below is the driver behaviour for vlan_tag_strip loadable paramter,
> 	vlan_tag_strip - 0: Don't strip the vlan tag
> 	vlan_tag_strip - 1: Always strip the vlan tag
> 	vlan_tag_strip - 2 (default): strip the vlan tag if the 
> 	  vlan group is not NULL.
> 
> Signed-off-by: Santoshkumar Rastapur <santosh.rastapur@neterion.com>
> Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> ---
> diff -Nurp 2.0.26.6/drivers/net/s2io.c 2.0.26.8P1/drivers/net/s2io.c
> --- 2.0.26.6/drivers/net/s2io.c	2007-11-15 18:19:42.000000000 -0800
> +++ 2.0.26.8P1/drivers/net/s2io.c	2007-11-15 18:15:00.000000000 -0800
> @@ -46,10 +46,10 @@
>   *     Possible values '1' for enable and '0' for disable. Default is '1'
>   * ufo: This parameter used to enable/disable UDP Fragmentation Offload(UFO)
>   *      Possible values '1' for enable and '0' for disable. Default is '0'
> - * vlan_tag_strip: This can be used to enable or disable vlan stripping.
> - *                 Possible values '1' for enable , '0' for disable.
> - *                 Default is '2' - which means disable in promisc mode
> - *                 and enable in non-promiscuous mode.
> + * vlan_tag_strip: This can be used to enable or disable vlan tag stripping.
> + *      Possible values '2' for driver default, '1' for enable and
> + *      '0' for disable
> + *      Default is '2' - VLAN tag stripping enabled if vlan group present
>   ************************************************************************/

this should be controlled via ethtool and behave like other net drivers


