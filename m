From: Dave Jones <davej@redhat.com>
Subject: Re: 3.5.1 fib_rules_lookup oops
Date: Mon, 20 Aug 2012 13:22:40 -0400
Message-ID: <20120820172240.GA378@redhat.com>
References: <20120820164428.GA27910@redhat.com>
 <1345481979.5158.333.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63071 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754044Ab2HTRWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 13:22:45 -0400
Content-Disposition: inline
In-Reply-To: <1345481979.5158.333.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 20, 2012 at 06:59:39PM +0200, Eric Dumazet wrote:
 > On Mon, 2012-08-20 at 12:44 -0400, Dave Jones wrote:
 > > Just had a user report this, which I don't think I've seen reported here yet.
 > > Something new, or just something missing from -stable ?
 > > 
 > > 	Dave
 > > 
 > > 
 > > BUG: unable to handle kernel paging request at 5f726571
 > > IP: [<c0884808>] fib_rules_lookup+0x38/0x130
 > > *pdpt = 000000002b8ef001 *pde = 0000000000000000 
 > > Oops: 0000 [#1] SMP 
 > 
 > It looks like a buffer overflow or memory reuse
 > 
 > 5f726565 is not a valid pointer, but ASCII "eer_"

Yeah.

Same user reported a slew of other problems, so he may have bad hardware.
I've asked him to run a memtest to rule that out.

	Dave
