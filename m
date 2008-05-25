From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of IRQF_SAMPLE_RANDOM
Date: Sun, 25 May 2008 21:33:45 +0200
Message-ID: <m33ao689gm.fsf@ursa.amorsen.dk>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com> <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com> <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com> <482C8D4D.3040702@garzik.org> <20080516132107.GA11304@csclub.uwaterloo.ca> <20080516161029.44ded734@core> <20080516173610.GA27126@csclub.uwaterloo.ca> <20080516191125.46f59ad6@core> <m31w42gf97.fsf@ursa.amorsen.dk> <1211727722.5913.63.camel@andromache>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:38157 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755312AbYEYTeD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 May 2008 15:34:03 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1K0Lyf-00006O-8I
	for netdev@vger.kernel.org; Sun, 25 May 2008 19:33:57 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 25 May 2008 19:33:57 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 25 May 2008 19:33:57 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glen Turner <gdt@gdt.id.au> writes:

> On Fri, 2008-05-16 at 22:34 +0200, Benny Amorsen wrote:
>
>> Perhaps it would be possible to make most types of interrupts add
>> entropy, but not credit any entropy?
>
> You need to be certain that those sources are not able
> to be influenced by a hostile party, otherwise the entropy
> pool can be degraded to be less random over successive samples
> than its entropy score suggests.

Not if we don't credit any entropy. /dev/random is engineered to be
safe against getting non-random input, as long as that input isn't
credited with entropy. /dev/random is even world writable by default.


/Benny


