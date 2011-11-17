From: Flavio Leitner <fbl@redhat.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 13:37:24 -0200
Message-ID: <20111117133724.59684d28@asterix.rh>
References: <4EC2CA52.6020104@icdsoft.com>
	<1321391355.2602.0.camel@edumazet-laptop>
	<4EC439F2.3080809@icdsoft.com>
	<20111116223330.08de9e52@asterix.rh>
	<4EC4C160.6010804@icdsoft.com>
	<20111117111145.252924f5@asterix.rh>
	<1321535747.2751.36.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Ivan Zahariev <famzah@icdsoft.com>, netdev@vger.kernel.org,
	Vasiliy Kulikov <segoon@openwall.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932267Ab1KQPho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 10:37:44 -0500
In-Reply-To: <1321540820.2751.47.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Nov 2011 15:40:20 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> [PATCH] ping: dont increment ICMP_MIB_INERRORS
> 
> ping module incorrectly increments ICMP_MIB_INERRORS if feeded with a
> frame not belonging to its own sockets.
> 
> RFC 2011 states that ICMP_MIB_INERRORS should count "the number of
> ICMP messages which the entiry received but determined as having
> ICMP-specific errors (bad ICMP checksums, bad length, etc.)."
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Vasiliy Kulikov <segoon@openwall.com>

Yeah, they aren't ICMP specific errors and the callers already
checked for checksum, lengths, and etc.. increasing that counter
when necessary.

Acked-by: Flavio Leitner <fbl@redhat.com>
