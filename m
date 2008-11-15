From: David Miller <davem@davemloft.net>
Subject: Re: net: add PCINet driver
Date: Sat, 15 Nov 2008 14:01:01 -0800 (PST)
Message-ID: <20081115.140101.160520099.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: iws@ovro.caltech.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50329
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752141AbYKOWBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 17:01:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You can't set that NETIF_F_NO_CSUM if there is every an
intermediate node that forwards or inspects the packets.

And really, it should never be used for situations where
packets leave a single kernel's realm.  Really, I don't
trust the PCI bus to never ever corrupt DMA's to my disk
so NETIF_F_NO_CSUM is certainly not appropriate here.

Please post a new version of your patch, and also please
include any changes you've made since V3.

Thanks.
