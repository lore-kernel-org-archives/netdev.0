From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/ibm/emac: bump version numbers for correct work
 with ethtool
Date: Mon, 28 Sep 2015 22:23:32 -0700 (PDT)
Message-ID: <20150928.222332.150002799807100193.davem@davemloft.net>
References: <20150925115227.636d658d@fr-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ben@decadent.org.uk
To: ivan@ru.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730AbbI2FXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 01:23:33 -0400
In-Reply-To: <20150925115227.636d658d@fr-ThinkPad-W520>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Mikhaylov <ivan@ru.ibm.com>
Date: Fri, 25 Sep 2015 11:52:27 +0400

> The size of the MAC register dump used to be the size specified by the
> reg property in the device tree.  Userland has no good way of finding
> out that size, and it was not specified consistently for each MAC type,
> so ethtool would end up printing junk at the end of the register dump
> if the device tree didn't match the size it assumed.
> 
> Using the new version numbers indicates unambiguously that the size of
> the MAC register dump is dependent only on the MAC type.
> 
> Fixes: 5369c71f7ca2 ("net/ibm/emac: fix size of emac dump memory areas")
> 
> Signed-off-by: Ivan Mikhaylov <ivan@ru.ibm.com>

Applied and queued up for -stable.
