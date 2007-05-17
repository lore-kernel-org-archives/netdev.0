From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Resending: RT patches expose netdev race [was Re: [RFC] [patch
	2/2] powerpc 2.6.21-rt1: fix kernel hang and/or panic
Date: Thu, 17 May 2007 10:49:45 +1000
Message-ID: <1179362985.32247.252.camel@localhost.localdomain>
References: <20070517002751.GC4325@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tsutomu OWA <tsutomu.owa@toshiba.co.jp>, linuxppc-dev@ozlabs.org,
	mingo@elte.hu, tglx@linutronix.de, cbe-oss-dev@ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49691 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756359AbXEQAur (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 20:50:47 -0400
In-Reply-To: <20070517002751.GC4325@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I do not know why sk_buff->head would be null, or
> would be set in a racy kind of way, or why the rt patches
> would cause this. But the evidence implicates that.

Would it be possible that a locking bug in spidernet would cause it
under some circumstances to get a stale skb pointer ?

Ben.


