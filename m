From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 02:00:38 +0400
Message-ID: <20060918220038.GB14322@ms2.inr.ac.ru>
References: <4492D5D3.4000303@atmos.washington.edu> <200609181754.37623.ak@suse.de> <20060918162847.GA4863@ms2.inr.ac.ru> <200609181850.22851.ak@suse.de> <20060918211759.GB31746@tentacle.sectorb.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Jesper Dangaard Brouer <hawk@diku.dk>,
	Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:5043 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S1751211AbWIRWAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2006 18:00:43 -0400
To: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Content-Disposition: inline
In-Reply-To: <20060918211759.GB31746@tentacle.sectorb.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Please think about it this way:
> suppose you haave a heavily loaded router and some network problem is to
> be diagnosed. You run tcpdump and suddenly router becomes overloaded (by
> switching to timestamp-it-all mode

I am sorry. I cannot think that way. :-)

Instead of attempts to scare, better resend original report,
where you said how much performance degraded, I cannot find it.

* I do see get_offset_pmtmr() in top lines of profile. That's scary enough.
* I do not undestand what the hell dhcp needs timestamps for.
* I do not listen any suggestions to screw up tcpdump with a sysctl.
  Kernel already implements much better thing then a sysctl.
  Do not want timestamps? Fix tcpdump, add an options, submit the
  patch to tcpdump maintainers. Not a big deal. 

Alexey
