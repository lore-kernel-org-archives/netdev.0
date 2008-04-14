From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Sink IPv6 options into its own submenu
Date: Sun, 13 Apr 2008 23:30:30 -0700 (PDT)
Message-ID: <20080413.233030.124079646.davem@davemloft.net>
References: <alpine.LNX.1.10.0804060603590.30794@fbirervta.pbzchgretzou.qr>
	<20080413.214319.245612757.davem@davemloft.net>
	<alpine.LNX.1.10.0804140747330.9651@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jengelh@computergmbh.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56974
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752764AbYDNGa3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 02:30:29 -0400
In-Reply-To: <alpine.LNX.1.10.0804140747330.9651@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@computergmbh.de>
Date: Mon, 14 Apr 2008 07:49:24 +0200 (CEST)

> 
> On Monday 2008-04-14 06:43, David Miller wrote:
> >
> >I think there is some standard pine/alpine setting change
> >that gets rid of this problem.
> >
> yeah is some kind of obscure pine bug.
> 
> commit 9ad0be1e95f326b03ccc513ec1cb5cc618ab2811
> Author: Jan Engelhardt <jengelh@computergmbh.de>
> Date:   Mon Mar 31 11:44:02 2008 +0200
> 
>     [NET]: Sink IPv6 menuoptions into its own submenu
>     
>     Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>

This patch doesn't apply cleanly to the current net-2.6.26 tree
because of the new ipv6 multicasting config options in
net/ipv6/Kconfig

I'm tired of going back and forth with you on this, so I fixed the
patch up myself.

Please be more mindful next time, thanks!
