From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 2/3]S2io: Support for add/delete/store/restore
 ethernet addresses
Date: Fri, 31 Aug 2007 11:36:04 -0700 (PDT)
Message-ID: <20070831.113604.29572801.davem@davemloft.net>
References: <Pine.GSO.4.10.10708220206510.22078-100000@guinness>
	<46D81777.2090700@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sreenivasa.Honnur@neterion.com, netdev@vger.kernel.org,
	support@neterion.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34477
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965716AbXHaSgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 14:36:05 -0400
In-Reply-To: <46D81777.2090700@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 31 Aug 2007 09:28:23 -0400

> Sreenivasa Honnur wrote:
> > - Support to add/delete/store/restore 64 and 128 Ethernet addresses for
> > Xframe I and Xframe II respectively.
> > 
> > Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> > Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
> 
> What is the purpose of this?  We do not support more than one unicast 
> MAC address at present...

Yes we do, the card can register with the card in ->set_rx_mode() or
enable promiscuous mode if it has no alternate MAC facility.

See netdev->uc_list.
