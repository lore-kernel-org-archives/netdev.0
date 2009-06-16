From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 02:21:31 -0700 (PDT)
Message-ID: <20090616.022131.267374816.davem@davemloft.net>
References: <20090615.050449.144947903.davem@davemloft.net>
	<20090616091538.GA4184@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40473
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751321AbZFPJV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:21:28 -0400
In-Reply-To: <20090616091538.GA4184@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 16 Jun 2009 11:15:38 +0200

> BUG: sleeping function called from invalid context at net/core/sock.c:1851

This line in my tree (and Linus's) reads:

	if (sk->sk_lock.owned)

what gives? :-)
