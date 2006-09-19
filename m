From: Andi Kleen <ak@suse.de>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 22:43:27 +0200
Message-ID: <200609192243.27511.ak@suse.de>
References: <20060918162847.GA4863@ms2.inr.ac.ru> <20060918.142247.14844785.davem@davemloft.net> <20060919203105.GF18349@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	master@sectorb.msk.ru, hawk@diku.dk, harry@atmos.washington.edu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:32180 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1752067AbWISUno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 16:43:44 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060919203105.GF18349@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> It seems only natural to me that the real problem is the slow
> clock source which needs to be resolved regardless of the
> outcome of this discussion. I believe that updating the stamp
> at socket enqueue time is the right thing to do but it shouldn't
> be considered as a solution to the performance problem.

While I agree it would be nice to fix that particular issue 
(it's unfortunately hard) slow clock sources in general won't go
away. They are also in lots of other platforms.

And even if you have a fast clock source not using it when you
don't need to is better. For example some x86s can be quite
slow even reading TSCs. It's much better than pmtmr
it's still is a expensive operations that is best avoided.

-Andi

