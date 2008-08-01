From: David Miller <davem@davemloft.net>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
 __netif_schedule+0x2c/0x98()
Date: Thu, 31 Jul 2008 21:27:29 -0700 (PDT)
Message-ID: <20080731.212729.138736823.davem@davemloft.net>
References: <20080726.173434.48036095.davem@davemloft.net>
	<20080727203757.GA2527@ami.dom.local>
	<20080731.052932.110299354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@axxeo.de, peterz@infradead.org,
	Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58743
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751494AbYHAE13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 00:27:29 -0400
In-Reply-To: <20080731.052932.110299354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 31 Jul 2008 05:29:32 -0700 (PDT)

> It's late here, but I'll start testing the following patch on my
> multiqueue capable cards after some sleep.

As a quick followup, I tested this on a machine where I had
a multiqueue interface and could reproduce the lockdep warnings,
and the patch makes them go away.

So I've pushed the patch into net-2.6 and will send it to Linus.
