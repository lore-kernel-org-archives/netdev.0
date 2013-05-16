From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next] tcp: speedup tcp_fixup_rcvbuf()
Date: Thu, 16 May 2013 09:06:20 +0200
Message-ID: <1697330.SmXeaasf9r@cpaasch-mac>
References: <1368681955.3301.11.camel@edumazet-glaptop>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:37337 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753708Ab3EPHG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 03:06:27 -0400
Received: by mail-ee0-f47.google.com with SMTP id t10so1537262eei.20
        for <netdev@vger.kernel.org>; Thu, 16 May 2013 00:06:26 -0700 (PDT)
In-Reply-To: <1368681955.3301.11.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Eric,

On Wednesday 15 May 2013 22:25:55 Eric Dumazet wrote:
> tcp_fixup_rcvbuf() contains a loop to estimate initial socket
> rcv space needed for a given mss. With large MTU (like 64K on lo),
> we can loop ~500 times and consume a lot of cpu cycles.
> 
> perf top of 200 concurrent netperf -t TCP_CRR

just out of curiosity, how do you run 200 concurrent netperfs?
Is there an option as in iperf (-P) ?
I did not find anything like this in the netperf-code.


Thanks,
Christoph

-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://multipath-tcp.org
UCLouvain
--
