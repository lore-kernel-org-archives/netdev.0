From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: lantiq_etop: use phydev from struct
 net_device
Date: Mon, 04 Jul 2016 16:01:18 -0700 (PDT)
Message-ID: <20160704.160118.1628564355789371621.davem@davemloft.net>
References: <1467497105-19935-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, sudipm.mukherjee@gmail.com, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, fw@strlen.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [184.105.139.130] ([184.105.139.130]:50996 "EHLO
	shards.monkeyblade.net" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753490AbcGDXBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 19:01:19 -0400
In-Reply-To: <1467497105-19935-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  3 Jul 2016 00:05:04 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
