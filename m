From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] net/802/mrp: fix lockdep splat
Date: Tue, 14 May 2013 23:01:45 +0300
Message-ID: <0a30a716234b9f33d1623d778fd4292e@visp.net.lb>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
 <1368447851.13473.119.camel@edumazet-glaptop>
 <16b0a5ee4602cb9005dd67ea7ad0d4e8@visp.net.lb>
 <20130514.120754.1745967383330029903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, amwang@redhat.com, david.ward@ll.mit.edu,
	hayeswang@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:39725 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755008Ab3ENUBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 16:01:48 -0400
In-Reply-To: <20130514.120754.1745967383330029903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-05-14 22:07, David Miller wrote:
> From: Denys Fedoryshchenko <denys@visp.net.lb>
> Date: Mon, 13 May 2013 15:53:30 +0300
> 
> Thank you for superfast answer :)
> It is changed a bit, but not disappeared. Relevant part from new
> dmesg:
> 
> Can you double check that you really had Eric's patch applied?
> lockdep appears to be complaining about the same thing in your
> log dump, as if the patch was not really applied.
> 
> It's saying that app->lock can be taken from the join timer in
> softirq, but mrp_uninit_applicant() takes it without disabling
> softirqs.
> 
> Eric's patch explicitly fixes this, by making sure that spin_lock_bh()
> is used there.
I will reapply patch on clean kernel and try again.

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
