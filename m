From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] l2tp: fix UDP checksum support
Date: Tue, 16 Dec 2008 01:24:03 -0800 (PST)
Message-ID: <20081216.012403.251778288.davem@davemloft.net>
References: <200812141641.mBEGf8Lq021173@bert.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34335
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754532AbYLPJYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 04:24:02 -0500
In-Reply-To: <200812141641.mBEGf8Lq021173@bert.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Sun, 14 Dec 2008 16:41:08 GMT

> The pppol2tp driver has had broken UDP checksum code for a long
> time. This patch fixes it. If UDP checksums are enabled in the
> tunnel's UDP socket, the L2TP driver now properly validates the
> checksum on receive and fills in the checksum on transmit. If the
> network device has hardware checksum support and is enabled, it is
> used instead of generating/checking the checksum in software.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

I've applied this to net-next-2.6, thanks James.
