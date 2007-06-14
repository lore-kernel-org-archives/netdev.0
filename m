From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [ANNOUNCE] new driver ixgbe for Intel(R) 10GbE PCI Express adapters.
Date: Thu, 14 Jun 2007 22:36:39 +0200
Message-ID: <20070614203639.GA23266@electric-eye.fr.zoreil.com>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070613230513.GB22521@electric-eye.fr.zoreil.com> <ae4a4a920706131706m6993e96bhdab638850b4769cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com,
	arjan@linux.intel.com, akpm@linux-foundation.org
To: Ayyappan Veeraiyan <Ayyappan.Veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59688 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751912AbXFNUhh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 16:37:37 -0400
Content-Disposition: inline
In-Reply-To: <ae4a4a920706131706m6993e96bhdab638850b4769cf@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayyappan Veeraiyan <Ayyappan.Veeraiyan@intel.com> :
[...]
> netpoll_send_skb should not deadlock because ixgbe_xmit_frame should
> bail out because of this...
> 
>      if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
>               /* Collision - tell upper layer to requeue */
>               return NETDEV_TX_LOCKED;
> 
> Right?

Yes.

-- 
Ueimor
