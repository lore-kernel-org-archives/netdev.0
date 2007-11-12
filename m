From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when promiscuous
 mode
Date: Mon, 12 Nov 2007 16:43:24 -0600
Message-ID: <4738D70C.4060404@nortel.com>
References: <47365200.0f10240a.0686.2173@mx.google.com> <47388988.1000506@intel.com>	<47388B9F.7050308@trash.net> <20071112.143342.10809862.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, auke-jan.h.kok@intel.com, joonwpark81@gmail.com,
	netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:61219 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285AbXKLWnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 17:43:55 -0500
In-Reply-To: <20071112.143342.10809862.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> When you select VLAN, you by definition are asking for non-VLAN
> traffic to be elided.  It is like plugging the ethernet cable
> into one switch or another.

For max functionality it seems like the raw eth device should show 
everything on the wire in promiscuous mode.

If we want to sniff only the traffic for a specific vlan, we can sniff 
the vlan device.

Chris
