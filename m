From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 01:18:00 +0400
Message-ID: <20060918211759.GB31746@tentacle.sectorb.msk.ru>
References: <4492D5D3.4000303@atmos.washington.edu> <200609181754.37623.ak@suse.de> <20060918162847.GA4863@ms2.inr.ac.ru> <200609181850.22851.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Harry Edmon <harry@atmos.washington.edu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tentacle.snto-msu.net ([194.88.210.4]:45718 "EHLO
	tentacle.sectorb.msk.ru") by vger.kernel.org with ESMTP
	id S1751192AbWIRVSC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 17:18:02 -0400
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <200609181850.22851.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2006 at 06:50:22PM +0200, Andi Kleen wrote:
> 
> I suppose in the worst case a sysctl like Vladimir asked for could be added,
> but it would seem somewhat lame.
> 
Please think about it this way:
suppose you haave a heavily loaded router and some network problem is to
be diagnosed. You run tcpdump and suddenly router becomes overloaded (by
switching to timestamp-it-all mode), drops OSPF adjancecies etc. Users
are angry, and you can't diagnose anything. But with impresise
timestamps and maybe even with reordered packets you still have some
traces to analyze.
So, in this particular corner case it's not that lame.

Or maybe patching tcpdump will do better?
~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 

