From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 06:19:38 -0800 (PST)
Message-ID: <20071213.061938.86541759.davem@davemloft.net>
References: <47602B77.2090202@intel.com>
	<b25c3fa70712122341q3ba282cdqda3fa56901b14484@mail.gmail.com>
	<47613E22.6060705@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, shemminger@linux-foundation.org,
	jesse.brandeburg@intel.com
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754580AbXLMOTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 09:19:39 -0500
In-Reply-To: <47613E22.6060705@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Thu, 13 Dec 2007 09:13:54 -0500

> If the netif_running() check is indeed required to make a device break
> out of napi polling and respond to an ifconfig down, then I think the
> netif_running() check should be moved up into net_rx_action() to avoid
> potential for driver complexity and bugs like the ones you found.

That, or something like it, definitely sounds reasonable and much
better than putting the check into every driver :-)
