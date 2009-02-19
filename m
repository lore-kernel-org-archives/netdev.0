From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Optimize skb_tx_hash() by eliminating a comparison
Date: Wed, 18 Feb 2009 17:55:13 -0800 (PST)
Message-ID: <20090218.175513.255155958.davem@davemloft.net>
References: <20090218092016.25153.14234.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, krkumar2@in.ibm.com
To: krikku@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54152
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756073AbZBSBz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:55:29 -0500
In-Reply-To: <20090218092016.25153.14234.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krikku@gmail.com>
Date: Wed, 18 Feb 2009 14:50:16 +0530

> Optimize skb_tx_hash() by eliminating a comparison that executes for
> every packet. skb_tx_hashrnd initialization is moved to a later part of
> the startup sequence, namely after the "random" driver is initialized.
> 
> Rebooted the system three times and verified that the code generates
> different random numbers each time.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied to net-next-2.6, thank you!
