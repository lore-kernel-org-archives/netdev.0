From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] macvtap: add GSO/csum offload support
Date: Thu, 18 Feb 2010 14:11:39 -0800 (PST)
Message-ID: <20100218.141139.263545698.davem@davemloft.net>
References: <20100215.215341.66627877.davem@davemloft.net>
	<201002181644.29740.arnd@arndb.de>
	<201002181648.17390.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, kaber@trash.net, eswierk@aristanetworks.com,
	netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50839
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753151Ab0BRWLX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2010 17:11:23 -0500
In-Reply-To: <201002181648.17390.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 18 Feb 2010 16:48:17 +0100

> Added flags field to macvtap_queue to enable/disable processing of
> virtio_net_hdr via IFF_VNET_HDR. This flag is checked to prepend virtio_net_hdr
> in the receive path and process/skip virtio_net_hdr in the send path.
> 
> Original patch by Sridhar, further changes by Arnd.
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
