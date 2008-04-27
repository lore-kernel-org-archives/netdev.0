From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][NET_SCHED] sch_sfq: use del_timer_sync() in
	sfq_destroy()
Date: Sun, 27 Apr 2008 21:00:44 +0200
Message-ID: <20080427190044.GA7747@ami.dom.local>
References: <20080427125921.GA7480@ami.dom.local> <4814C4E2.50600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:43507 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757866AbYD0TCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 15:02:54 -0400
Received: by fg-out-1718.google.com with SMTP id l27so4610834fgb.17
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2008 12:02:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4814C4E2.50600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 27, 2008 at 08:24:34PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> [NET_SCHED] sch_sfq: use del_timer_sync() in sfq_destroy()
>>
>> Let's delete timer reliably in sfq_destroy().
>
> This is broken, we hold dev->queue_lock in ->destroy.
>

But sfq timer (sfq_perturbation()) doesn't use this timer...
Could you explain your point more?

Thanks,
Jarek P.
