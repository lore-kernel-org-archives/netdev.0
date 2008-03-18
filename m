From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [AX25] kernel panic
Date: Tue, 18 Mar 2008 22:25:32 +0100
Message-ID: <20080318212531.GA2031@electric-eye.fr.zoreil.com>
References: <47DF9D21.20807@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Bernard Pidoux F6BVP <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:51610 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754087AbYCSTaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:30:11 -0400
Content-Disposition: inline
In-Reply-To: <47DF9D21.20807@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bernard Pidoux F6BVP <f6bvp@free.fr> :
[...]
> I used netconsole to document a kernel panic related to AX25 on one of my 
> systems.
> This occurs systematically as soon as I close an AX25 session established 
> through a level 3 ROSE network (FPAC) via AXUDP link (ax25ipd).
> It is not triggered when connecting locally or via AX25 call through LAN.

May be replacing netif_rx() in drivers/net/hamradio/mkiss.c::ax_bump()
by netif_receive_skb() ?

-- 
Ueimor
