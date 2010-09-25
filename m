From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when
 able to sleep
Date: Fri, 24 Sep 2010 22:37:09 -0700 (PDT)
Message-ID: <20100924.223709.233700415.davem@davemloft.net>
References: <20100923212012.GA10925@electric-eye.fr.zoreil.com>
	<20100924131842.26f1fb1f@dhcp-lab-109.englab.brq.redhat.com>
	<20100924222434.GA7743@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34388
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754788Ab0IYFgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 01:36:50 -0400
In-Reply-To: <20100924222434.GA7743@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 25 Sep 2010 00:24:34 +0200

> Stanislaw Gruszka <sgruszka@redhat.com> :
>> Francois Romieu <romieu@fr.zoreil.com> wrote:
> [...]
>> Anyway atomic allocation should not be used in process context.
> 
> What do you mean ? tg3->open() does not seem to bother. It is not alone.

I think this is merely an indication that r8169 is more often
used in systems that actually suspend/resume than tg3 is.  tg3
ought to be doing this too for correctness, as should pretty much
every network driver.

Stanislaw's patches are very reasonable, especially if the problem
is happening.

But yes a "Tested-by: " confirming the fix would really be
appeciated before we apply this.
