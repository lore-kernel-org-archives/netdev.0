From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] wireless: convert to use
 netdev_for_each_mc_addr
Date: Wed, 03 Mar 2010 02:01:52 -0800 (PST)
Message-ID: <20100303.020152.52760707.davem@davemloft.net>
References: <20100303114506.19575pbsu8yz2kjk@hayate.sektori.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org
To: jussi.kivilinna@mbnet.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34880
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750829Ab0CCKBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 05:01:34 -0500
In-Reply-To: <20100303114506.19575pbsu8yz2kjk@hayate.sektori.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Date: Wed, 03 Mar 2010 11:45:06 +0200

> Hello!
> 
> Added locking broke rndis_wlan, rndis_set_oid/rndis_command
> sleeps. Also there is kmalloc(..., GFP_KERNEL) within lock/unlock.

Jiri please fix this.
