From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it
 occupies too many slots
Date: Fri, 16 May 2014 07:21:08 -0700
Message-ID: <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com>
	 <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140516131145.GK18551@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xen.org,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:34245 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754594AbaEPOVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 10:21:11 -0400
Received: by mail-pb0-f54.google.com with SMTP id jt11so2685551pbb.27
        for <netdev@vger.kernel.org>; Fri, 16 May 2014 07:21:10 -0700 (PDT)
In-Reply-To: <20140516131145.GK18551@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-05-16 at 14:11 +0100, Wei Liu wrote:

> It's not that common to trigger this, I only saw a few reports. In fact
> Stefan's report is the first one that comes with a method to reproduce
> it.
> 
> I tested with redis-benchmark on a guest with 256MB RAM and only saw a
> few "failed to linearize", never saw a single one with 1GB guest.

Well, I am just saying. This is asking order-5 allocations, and yes,
this is going to fail after few days of uptime, no matter what you try.
