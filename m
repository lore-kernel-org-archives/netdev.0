From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Thu, 2 Jul 2009 22:05:26 +0200
Message-ID: <20090702200526.GA2969@elte.hu>
References: <20090630.213927.180401151.davem@davemloft.net> <20090702075724.GA10608@elte.hu> <4A4C9125.8020705@gmail.com> <4A4CBE7D.2060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:46632 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756607AbZGBUFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 16:05:35 -0400
Content-Disposition: inline
In-Reply-To: <4A4CBE7D.2060603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Eric Dumazet <eric.dumazet@gmail.com> wrote:

> We might have a race in napi_schedule(), leaving interrupts 
> disabled forever. I cannot test this patch, I dont have the 
> hardware...

I have tested it and the config that failed before works now. (as do 
other configs as well)

I'll have to re-test whether the failing config fails with your fix 
reverted - that will have to wait until tomorrow or so.

	Ingo
