From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] net: Fix struct sock bitfield annotation
Date: Fri, 9 Oct 2009 15:39:55 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0910091539170.32209@gentwo.org>
References: <4ACE023D.9030208@gmail.com> <19f34abd0910081454v51455ee0p30ad6715b5ee31c0@mail.gmail.com> <4ACE8CEC.3020905@gmail.com> <4ACE95E1.30301@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:47921 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754712AbZJITrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 15:47:05 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0724582C495
	for <netdev@vger.kernel.org>; Fri,  9 Oct 2009 15:50:28 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id H1TClgsducVt for <netdev@vger.kernel.org>;
	Fri,  9 Oct 2009 15:50:27 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D0F1C82C644
	for <netdev@vger.kernel.org>; Fri,  9 Oct 2009 15:50:15 -0400 (EDT)
In-Reply-To: <4ACE95E1.30301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Oct 2009, Eric Dumazet wrote:

> For networking guys, here is the actual mess with "struct sock" on x86_64,
> related to UDP handling (critical latencies for some people). We basically touch
> all cache lines, in every paths, bad effects on SMP...

Please keep me posted on this. I am very interested in this work.

Some simple shuffling around may do some good here.

