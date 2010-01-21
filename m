From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/11] sky2: fix DMA sync_single length error
Date: Wed, 20 Jan 2010 16:15:34 -0800 (PST)
Message-ID: <20100120.161534.173867444.davem@davemloft.net>
References: <20100120.154126.152942350.davem@davemloft.net>
	<20100120235920.GF3072@del.dom.local>
	<20100120160407.3a365a92@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45739
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754736Ab0AUAPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2010 19:15:24 -0500
In-Reply-To: <20100120160407.3a365a92@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 20 Jan 2010 16:04:07 -0800

> The usage of jumbo frames on the Marvell Yukon-2 chip version that
> Michael has is suspect. In order to do Jumbo frames, the driver has
> turns off the store-forward buffer; this reduces the window for transmit
> underrun, and triggers a problem.  I suspect the unwind logic for
> transmit underrun is broken and may not be fixable without more hardware
> information.  Turning off jumbo frame support for that chip type
> is probably the safest solution.

So let's do that.

Meanwhile I think the DMA debugging patch you posted earlier today
need a little work, will reply there.

