From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 0/3] macvlan: support for guest vm direct rx/tx
Date: Sat, 28 Nov 2009 00:43:58 +0100
Message-ID: <200911280043.58784.arnd@arndb.de>
References: <4AFAD86A.9070506@trash.net> <20091113195201.11184.25766.stgit@mimic.site> <20091113132728.0f1db7c5@s6510>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick Mullaney <pmullaney@novell.com>, kaber@trash.net,
	netdev@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49523 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbZK0Xn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 18:43:58 -0500
In-Reply-To: <20091113132728.0f1db7c5@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 13 November 2009, Stephen Hemminger wrote:
> Also, macvlan should really being calling netif_receive_skb()
> not going through another queue/softirq cycle.

I've added a patch for this in my experimental queue now.
When I last tried this, I saw a kernel stack overflow
but it seems fine now.

I wonder if we can also return from the macvlan hook with
skb->dev changed to netif_receive_skb rather than calling it
recursively.

	Arnd <><
