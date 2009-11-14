From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] s2io: fixing a ethtool test that is broken
Date: Fri, 13 Nov 2009 19:57:37 -0800 (PST)
Message-ID: <20091113.195737.60156534.davem@davemloft.net>
References: <1257882263-7507-1-git-send-email-leitao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sreenivasa.honnur@neterion.com
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35598
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757764AbZKND5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:57:21 -0500
In-Reply-To: <1257882263-7507-1-git-send-email-leitao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: leitao@linux.vnet.ibm.com
Date: Tue, 10 Nov 2009 14:44:23 -0500

> Due commit 4b77b0a2ba27d64f58f16d8d4d48d8319dda36ff, it is not more
> possible to pci_restore_state() more than once without calling
> pci_save_state() in the middle.
> 
> Actually running a ethtool test on s2io makes the card inactive, 
> and it needs to unload/reload the module to fix. 
> 
> This patch just save the state just after it restore in order to
> keep the old behaviour
> 
> Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

Applied.
