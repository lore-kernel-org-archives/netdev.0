From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 18/18] flag parameters: check magic constants
Date: Mon, 12 May 2008 21:39:25 -0700 (PDT)
Message-ID: <20080512.213925.193699728.davem@davemloft.net>
References: <482910FA.1080703@redhat.com>
	<20080512.210225.167924945.davem@davemloft.net>
	<48291749.1060400@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55618
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753655AbYEMEja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 00:39:30 -0400
In-Reply-To: <48291749.1060400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Drepper <drepper@redhat.com>
Date: Mon, 12 May 2008 21:21:29 -0700

> Is MIPS really a problem?  The value is 0x80.  128 protocol types should
> be enough.  Even if not, there is no reason why the numbers should be
> consecutive.  It's easy enough to skip over a bit.  I.e., after procotol
> 0x7f the next one would be 0x100.

Indeed, MIPS looks good.

> And PA seems to have gotten O_NONBLOCK wrong.  SPARC does it right AFAICS.

I agree.

But that value is compiled into every parisc binary out there,
limiting what we can do about it in the short term.
