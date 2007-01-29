From: Baruch Even <baruch@ev-en.org>
Subject: Re: net-2.6.21 GIT tree
Date: Mon, 29 Jan 2007 09:25:52 +0200
Message-ID: <20070129072552.GM22455@galon.ev-en.org>
References: <20070128.165441.125893049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:11508
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933254AbXA2HZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 02:25:54 -0500
Content-Disposition: inline
In-Reply-To: <20070128.165441.125893049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070129 02:54]:
> 
> I just cut it at:
> 
> 	kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.21.git
> 
> Feel free to send me feature patches for consideration.
> 
> I'll probably toss things like Baruch's latest SACK fixes in
> there so they can cook for a while and then perhaps after some
> time we'll backport them into whatever -stable branch is active
> at the time.

The new fixes are much less important than the first one so I have no
problem with them waiting a bit. I do think that only actively testing
the SACK processing correctness and performance will show anything. It's
been shown time and again that most peoples just take the existing
behaviour as ok even if it is inefficient at best.

I'll try to get access to a network testbed or setup a virtual one on my
laptop and actually test this code.

Baruch
