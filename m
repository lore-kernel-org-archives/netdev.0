From: "Vladimir B. Savkin" <master@sectorb.msk.ru>
Subject: Re: Packet timestamps (was: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20)
Date: Tue, 6 Mar 2007 21:15:00 +0300
Message-ID: <20070306181459.GA12037@tentacle.sectorb.msk.ru>
References: <200609181850.22851.ak@suse.de> <200703061538.45049.dada1@cosmosbay.com> <20070306144315.GA9036@tentacle.sectorb.msk.ru> <200703061616.24959.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, Andi Kleen <ak@suse.de>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	David Miller <davem@davemloft.net>, hawk@diku.dk,
	harry@atmos.washington.edu, linux-kernel@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tentacle.s2s.msu.ru ([193.232.119.109]:35200 "EHLO
	tentacle.sectorb.msk.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965518AbXCFSPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 13:15:04 -0500
Content-Disposition: inline
In-Reply-To: <200703061616.24959.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 06, 2007 at 04:16:24PM +0100, Eric Dumazet wrote:
> 
> It would be better to name the tunable "disable_timestamps", default 0 of 
> course.... 

I agree.
If networking maintainers are interested, I surely can prepare a patch.

But IMO some way to force TSC usage on x86_64 will be even better.

> It would better describe what your patch is actually doing : Even if a tcpdump 
> is running (so asking for timestamps), it wont have them because the sysctl 
> disabled them.

Well, tcpdump will have timestamps, but taken at wrong moment.
But some other applications (that use ip_queue, ulog etc.) will not,
as I understand.

> 
> Thank you
> 
~
:wq
                                        With best regards, 
                                           Vladimir Savkin. 

