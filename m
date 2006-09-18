From: Andi Kleen <ak@suse.de>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 18 Sep 2006 18:50:22 +0200
Message-ID: <200609181850.22851.ak@suse.de>
References: <4492D5D3.4000303@atmos.washington.edu> <200609181754.37623.ak@suse.de> <20060918162847.GA4863@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Vladimir B. Savkin" <master@sectorb.msk.ru>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:62641 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751843AbWIRQua (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 12:50:30 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060918162847.GA4863@ms2.inr.ac.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 18 September 2006 18:28, Alexey Kuznetsov wrote:
> Hello!
> 
> > Hmm, not sure how that could happen. Also is it a real problem
> > even if it could?
> 
> As I said, the problem is _occasionally_ theoretical.
> 
> This would happen f.e. if packet socket handler was installed
> after IP handler. Then tcpdump would get packet after it is processed
> (acked/replied/forwarded). This would be disasterous, the results
> are unparsable.

But that never happens right? 

And do you have some other prefered way to solve this? Even if the timer
was fast it would be still good to avoid it in the fast path when DHCPD
is running.

I suppose in the worst case a sysctl like Vladimir asked for could be added,
but it would seem somewhat lame.

-Andi
