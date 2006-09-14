From: David Miller <davem@davemloft.net>
Subject: Re: NIC interrupt assignments under UltraSPARC-T1
Date: Wed, 13 Sep 2006 18:14:14 -0700 (PDT)
Message-ID: <20060913.181414.41647370.davem@davemloft.net>
References: <4508A69F.8060102@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60053
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751304AbWINBNX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 21:13:23 -0400
To: rick.jones2@hp.com
In-Reply-To: <4508A69F.8060102@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 13 Sep 2006 17:47:27 -0700

> Is it indeed not possible to alter the interrupt assignments or have I 
> (as I'm wont to do) missed something quasi-obvious?

It should work, perhaps there is a bug somewhere.

I think it's a bad idea, btw, to asking sparc port questions
on the netdev list :-)  sparclinux@vger would be a much
better place.

I'm travelling currently, and won't be back until next week,
so I have no way to plug in and power on my T1000 machine to
try and diagnose this.  Please try and debug this yourself by
poking around in arch/sparc64/kernel/irq.c where this is supposed
to be happening.

Thanks.
