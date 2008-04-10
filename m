From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.26 1/3][TUN][NETNS]: Introduce the tun_net
 structure.
Date: Thu, 10 Apr 2008 03:29:21 -0700 (PDT)
Message-ID: <20080410.032921.216641570.davem@davemloft.net>
References: <47F38F1D.2060605@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44961
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751605AbYDJK3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 06:29:20 -0400
In-Reply-To: <47F38F1D.2060605@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 02 Apr 2008 17:50:21 +0400

> This is the first step in making tuntap devices work in net 
> namespaces. The structure mentioned is pointed by struct net 
> and tun driver will fill this one on load. It will contain only 
> the tun devices list.
> 
> So declare this structure and introduce net init and exit hooks.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I don't want struct net to become a dumping ground for
everything and anything that is networking and might
want to be namespace aware.

We are at the point where some kind of dynamic registry
is in order, don't you think?

I'm dropping these patches for now.
