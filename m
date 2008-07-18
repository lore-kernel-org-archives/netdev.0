From: David Miller <davem@davemloft.net>
Subject: Re: wierd networking problem on 2.6.26 with e1000
Date: Fri, 18 Jul 2008 00:12:56 -0700 (PDT)
Message-ID: <20080718.001256.149225461.davem@davemloft.net>
References: <alpine.DEB.1.10.0807172357390.6370@asgard>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org
To: david@lang.hm
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45836
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752695AbYGRHM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 03:12:57 -0400
In-Reply-To: <alpine.DEB.1.10.0807172357390.6370@asgard>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: david@lang.hm
Date: Fri, 18 Jul 2008 00:07:15 -0700 (PDT)

David please report networking problems with at least netdev CC:'d, thanks.
I've added it this time.

> apologies for the poor report, I'll learn more tomorrow.
> 
> I've got a pair of boxes dual opteron dual-core with 16G ram LSI raid, and 
> several quad E1000 cards. I had an emergancy requiring me to setup the 
> boxes quickly for a new purpose, on one of them I left my old 2.6.22.1 32 
> bit build, but on the other I tried a 2.6.26 64 bit build. both boxes have 
> the same 32 bit userspace and are running heartbeat to move a VIP from one 
> to the other.
> 
> when I logged into the 2.6.22.1 box and ssh'd over to the 2.6.26 box I had 
> no communications problems at all, but if I moved the VIP (eth0:0) onto 
> the 2.6.26 box and connected in to that I would occasionally see delays of 
> a min or two where I lost all communications with the box. At the time 
> this breakdown happened I was still connected in from the 2.6.22 box to 
> the real IP of the second one with no problems, but attempts to connect to 
> that real IP from other systems failed (unable to get an ARP response)
> 
> I will be able to post my configs tomorrow, but the version difference 
> between the two kernels will limit the usability of that. any suggestions 
> on other things I should do when I setup a new test?
> 
> David Lang
