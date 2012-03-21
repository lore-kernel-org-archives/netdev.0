From: Ranjeeth <ranjeeth34@gmail.com>
Subject: Re: [PATCH] Fix bug of update IPv4 PMTU when received ICMP Fragmentation Needed message
Date: Wed, 21 Mar 2012 11:40:31 +0000 (UTC)
Message-ID: <loom.20120321T123754-779@post.gmane.org>
References: <E1HuRAd-0002Wl-00@gondolin.me.apana.org.au> <46635F39.2090009@cn.fujitsu.com> <20070604025528.GA27750@gondor.apana.org.au> <46638F2D.90608@cn.fujitsu.com> <20070604041406.GA28263@gondor.apana.org.au> <466395F1.7060003@cn.fujitsu.com> <20070604045506.GA28580@gondor.apana.org.au> <4663A561.7070300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:45740 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757089Ab2CUMfG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2012 08:35:06 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1SAKkp-0007eO-Tv
	for netdev@vger.kernel.org; Wed, 21 Mar 2012 13:35:04 +0100
Received: from 203.91.193.7 ([203.91.193.7])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 13:35:03 +0100
Received: from ranjeeth34 by 203.91.193.7 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 13:35:03 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a new query regarding the jumbo frames support in ICMP.

I am supporting jumbo frame support for self tx/rx.

So I need to handle the icmp reply and request for size of 9000.

i was able to ping upto max 3000 size. more than that icmp echo response is not
generated????

why is this???

any limitation?
