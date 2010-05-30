From: David Miller <davem@davemloft.net>
Subject: Re: [Patch]8139too: remove unnecessary cast of ioread32()'s return
 value
Date: Sun, 30 May 2010 15:34:51 -0700 (PDT)
Message-ID: <20100530.153451.193700815.davem@davemloft.net>
References: <20100530122213.GB1146@host-a-55.ustcsz.edu.cn>
	<4C02A1F7.6030701@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41206
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752176Ab0E3Wel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 May 2010 18:34:41 -0400
In-Reply-To: <4C02A1F7.6030701@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Sun, 30 May 2010 13:35:51 -0400

> Have you verified this matches all architectures definition of
> readl()?

Jeff, when you come out of hiding after months if not years
of not reviewing network driver changes, could you provide
some useful commentary instead of some trite stuff like this?

It does match, that's why I told this person to write these patches.
And if you have been following the thread where we discussed this, you
wouldn't feel the need to ask this question about these two patches.

And if it doesn't match, that's an arch bug which should be fixed and
in any event there is only one possibility of a non-match and that is
if the routine returns "unsigned long"

Which, surprise surprise Jeff, retains current behavior!

So there is no risk whatsoever possible from this change.
