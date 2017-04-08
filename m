From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [regression v4.11] 617f01211baf ("8139too: use
 napi_complete_done()")
Date: Sat, 8 Apr 2017 12:23:05 +0200
Message-ID: <20170408102305.GA4522@electric-eye.fr.zoreil.com>
References: <20170407181754.GL30290@intel.com>
 <1491590329.10124.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170407.114216.29873489271414092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
        edumazet@google.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ville.syrjala@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:47533 "EHLO
        violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751397AbdDHKcu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 06:32:50 -0400
Content-Disposition: inline
In-Reply-To: <20170407.114216.29873489271414092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
[...]
> One theory is that the interrupt masking isn't working properly
> and interrupts are still arriving and hitting the NAPI state even
> when we are actively polling NAPI.
> 
> And this problem was masked by the locking done here.

Yes.

Ville, can you rule out irq sharing between the 8139 and some other
device ? It's a candidate for unexpected interrupt handler invocation
with older pc, even with properly working hardware.

-- 
Ueimor
