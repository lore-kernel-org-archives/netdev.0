From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] IPoIB: Fix unused variable warning
Date: Tue, 09 Oct 2007 16:17:50 -0700 (PDT)
Message-ID: <20071009.161750.02298910.davem@davemloft.net>
References: <20071009.135145.95506679.davem@davemloft.net>
	<adahckzhprc.fsf@cisco.com>
	<adad4vnhpoq.fsf_-_@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49792
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750930AbXJIXRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 19:17:50 -0400
In-Reply-To: <adad4vnhpoq.fsf_-_@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 09 Oct 2007 15:46:13 -0700

> The conversion to use netdevice internal stats left an unused variable
> in ipoib_neigh_free(), since there's no longer any reason to get
> netdev_priv() in order to increment dropped packets.  Delete the
> unused priv variable.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Jeff, do you want to merge in Roland's 4 patches to your tree then do
a sync with me so I can pull it all in from you?

Alternative I can merge in Roland's work directly if that's easier
for you.

Just let me know.
