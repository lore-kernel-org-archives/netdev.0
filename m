From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: remove a bogus PCI function number
 check
Date: Sun, 03 Oct 2010 22:07:36 -0700 (PDT)
Message-ID: <20101003.220736.246539527.davem@davemloft.net>
References: <1285874232-1554-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37765
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751738Ab0JDFHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 01:07:15 -0400
In-Reply-To: <1285874232-1554-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Thu, 30 Sep 2010 12:17:12 -0700

> Remove a bogus PCI function number check from the driver's .remove
> method that causes pci_release_regions not to be called for function 0
> if additional functions are attached and one of them is used as primary.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Applied, thanks.
