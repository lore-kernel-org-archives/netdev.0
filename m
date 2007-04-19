From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK] Don't attach callback to a going-away netlink socket
Date: Wed, 18 Apr 2007 17:06:36 -0700 (PDT)
Message-ID: <20070418.170636.77057313.davem@davemloft.net>
References: <4625D3D2.9030507@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org, devel@openvz.org, kaber@trash.net,
	dev@openvz.org
To: xemul@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48645
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030522AbXDSAGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2007 20:06:34 -0400
In-Reply-To: <4625D3D2.9030507@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelianov <xemul@sw.ru>
Date: Wed, 18 Apr 2007 12:16:18 +0400

> The proposal it to make sock_orphan before detaching the callback
> in netlink_release() and to check for the sock to be SOCK_DEAD in
> netlink_dump_start() before setting a new callback.

As discussed in this thread there might be other ways to a
approach this, but this fix is good for now.

Patch applied, thank you.
