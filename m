From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] vlan_dev: VLAN 0 should be treated as "no vlan tag" (802.1p packet)
Date: Wed, 16 Jun 2010 16:24:11 +0200
Message-ID: <201006161624.12101.arnd@arndb.de>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com> <4C18B898.4000307@trash.net> <6b5ed8108cebb1865c85e03d3244b6ed@dondevamos.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Patrick McHardy <kaber@trash.net>
To: Pedro Garcia <pedro.netdev@dondevamos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:59172 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517Ab0FPOZI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 10:25:08 -0400
In-Reply-To: <6b5ed8108cebb1865c85e03d3244b6ed@dondevamos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 June 2010, Pedro Garcia wrote:
> Probably a definitive fix would be not to allow the definition of VLAN 0 
> in 802.1q module and provide some other way to tag priority packets without
> using a subinterface (maybe in the same module or a new 8021p one). I am 
> having a look at the kernel to see what happens if we load two modules for 
> the same protocol. 

On a related note, we will also need to support 802.1Qad provider bridges
at some point, which use yet another variation of the VLAN header (actually
two nested VLAN tags) with a different ethertype.
I need this for 802.1Qbg multi-channel VEPA (possibly also 802.1Qbh
port extenders), but I have not yet investigated how to implement this
in the VLAN module.

> By the way, the changelog I have to write is just the text before the 
> patch?

Yes.

	Arnd
