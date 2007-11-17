From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] NET : rt_check_expire() can take a long time, add a cond_resched()
Date: Sat, 17 Nov 2007 14:08:26 +0100
Message-ID: <p73fxz5auk5.fsf@bingen.suse.de>
References: <473B69D5.2050805@cosmosbay.com> <p73r6isc6ev.fsf@bingen.suse.de>
	<473C0297.5090004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:50032 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbXKQNI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Nov 2007 08:08:28 -0500
In-Reply-To: <473C0297.5090004@cosmosbay.com> (Eric Dumazet's message of "Thu\, 15 Nov 2007 09\:25\:59 +0100")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <dada1@cosmosbay.com> writes:

> So it may sound unnecessary but in the rt_check_expire() case, with a
> loop potentially doing XXX.XXX iterations, being able to bypass the
> function call is a clear win (in my bench case, 25 ms instead of 88
> ms). Impact on I-cache is irrelevant here as this rt_check_expires()

Measuring what? And really milli-seconds? The number does not sound plausible 
to me.

-Andi

