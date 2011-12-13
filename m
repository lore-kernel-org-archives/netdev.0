From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/2] igb: offer a PTP Hardware Clock instead
 of the timecompare method
Date: Tue, 13 Dec 2011 05:40:20 +0100
Message-ID: <20111213044020.GA14322@netboy.at.omicron.at>
References: <cover.1323744724.git.richardcochran@gmail.com>
 <388385c50909f63bff239894c60dbb00abc65c93.1323744725.git.richardcochran@gmail.com>
 <1323746932.2583.33.camel@edumazet-laptop>
 <20111213034132.GC9604@netboy.at.omicron.at>
 <1323748349.2583.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:37407 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016Ab1LMEkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 23:40:25 -0500
Received: by eaaj10 with SMTP id j10so951091eaa.19
        for <netdev@vger.kernel.org>; Mon, 12 Dec 2011 20:40:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1323748349.2583.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2011 at 04:52:29AM +0100, Eric Dumazet wrote:
> > It is too bad that we have to take the spinlock for every time stamped
> > packet, but it is the hardware's fault for not providing a 64 bit wide
> > nanosecond time register.
> > 
> 
> Yes, probably. Are you sure a workaround is not possible, using a
> seqlock for synchronization of threads, and two hardware reads ?

Many things are possible...
 
> Or maybe it doesnt matter at all :)

Yes, I think it not worth the effort.  In general, the whole time
stamping thing is at odds with network throughput.

Richard
