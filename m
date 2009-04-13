From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 13084] New: page allocation failure. order:0,
 mode:0x20
Date: Mon, 13 Apr 2009 13:41:35 -0700 (PDT)
Message-ID: <20090413.134135.128634528.davem@davemloft.net>
References: <bug-13084-10286@http.bugzilla.kernel.org/>
	<20090413124228.be31e9f3.akpm@linux-foundation.org>
	<alpine.WNT.2.00.0904131255580.732@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, reeve.yang@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: jesse.brandeburg@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751627AbZDMUlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 16:41:44 -0400
In-Reply-To: <alpine.WNT.2.00.0904131255580.732@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Date: Mon, 13 Apr 2009 13:06:04 -0700 (Pacific Daylight Time)

> On Mon, 13 Apr 2009, Andrew Morton wrote:
>> You report is unclear.  Yes, the machine wedges up under the UDP load. 
>> But does it recover when the other machine stops spraying UDP packets
>> at this machine?  It _should_ recover.  If it does not, we have a bug
>> somewhere.
> 
> In this case kmem_cache_alloc is failing to get memory, being called by 
> the route_dst code, maybe someone on netdev can comment if this has been 
> fixed along the way.

Although I have some level of tolerance, there is zero way I'm
going to analyze anything on 2.6.17 kernels nor am I going to
encourage other core networking developers to waste their time
on this either.

It is easily the case that we've fixed 10's of thousands of
VM and networking bugs since then, if not more.

