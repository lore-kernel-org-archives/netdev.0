From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] mark MD5 as broken in older (stable) kernels
Date: Wed, 09 Jul 2008 16:48:00 -0700 (PDT)
Message-ID: <20080709.164800.167187868.davem@davemloft.net>
References: <396556a20807071021n2039fc8eo6ab343355e36b468@mail.gmail.com>
	<396556a20805301217k293e5718h6bbf02bfe069001@europa>
	<20080709095851.1f9da054@speedy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: agl@imperialviolet.org, netdev@vger.kernel.org
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51493
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752315AbYGIXsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 19:48:00 -0400
In-Reply-To: <20080709095851.1f9da054@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Wed, 9 Jul 2008 09:58:51 -0700

> The following should probably be sent to stable kernel tree to disable
> MD5 in older kernels. It will avoid problems for all those vendor
> kernels.

If we're going to take the time to fix this, we should take
the time to push a bug fix, not a disable, into -stable.

Part of this is my fault as I haven't had time to review
the MD5 fixes being posted since I want to fix the TX
multiqueue stuff so I can get it into 2.6.27, first.
