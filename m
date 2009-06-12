From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: do not bring device down when suspending
Date: Thu, 11 Jun 2009 17:22:57 -0700 (PDT)
Message-ID: <20090611.172257.90040273.davem@davemloft.net>
References: <20090611204850.GA26691@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aeriksson@fastmail.fm, netdev@vger.kernel.org,
	edward_hsu@realtek.com.tw
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51894
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751238AbZFLAWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 20:22:54 -0400
In-Reply-To: <20090611204850.GA26691@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 11 Jun 2009 22:48:51 +0200

> Stopping all activity through ChipCmd and blindly acking the irqs
> is neither nice nor completely needed: the transition to low-power
> mode does enough work and it apparently keeps the device in a sane
> state.
> 
> Patch suggested by a fix for http://bugzilla.kernel.org/show_bug.cgi?id=9512
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Tested-by: Anders Eriksson <aeriksson@fastmail.fm>

This patch does not apply to net-next-2.6

You're patching rtl8169_suspend(), but in net-next-2.6 it does nothing
but call a function named rtl8169_net_suspend() which actually has the
code you seem to be changing.

Please submit a fixed up patch and let me know if you want me to queue
this up to -stable.

Thanks.
