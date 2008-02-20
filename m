From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 2/4]S2io: Multiqueue network device support -
 FIFO selection based on L4 ports
Date: Wed, 20 Feb 2008 15:18:34 -0800 (PST)
Message-ID: <20080220.151834.133850272.davem@davemloft.net>
References: <47BCB304.9050709@trash.net>
	<20080220.151244.79005114.davem@davemloft.net>
	<47BCB481.8050203@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna.Vepa@neterion.com, Sreenivasa.Honnur@neterion.com,
	netdev@vger.kernel.org, jeff@garzik.org, support@neterion.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45048
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753482AbYBTXR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 18:17:58 -0500
In-Reply-To: <47BCB481.8050203@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 21 Feb 2008 00:15:13 +0100

> I missed those discussions, but this has already been agreed on,
> fine by me. It would still be preferable to use queue_mapping
> instead of priority IMO, even if its activated by a module
> parameter, since that leaves the option to use classifiers.

I think the driver should compute the value in it's transmit
routine and keep the value local.  It shouldn't be setting
skb->foo values at all, they don't belong to the driver
and this could confuse other code.
