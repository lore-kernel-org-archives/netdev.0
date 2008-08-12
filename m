From: Brian Haley <brian.haley@hp.com>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Mon, 11 Aug 2008 20:41:11 -0400
Message-ID: <48A0DC27.7030208@hp.com>
References: <20080809213101.0927a808.akpm@linux-foundation.org>	 <489F8827.4030904@hp.com>	 <82e4877d0808101805t55a6ec5ft6c9b171ac1c7c3ab@mail.gmail.com>	 <20080811.143212.172434871.davem@davemloft.net>	 <48A0CEEA.9080104@hp.com> <82e4877d0808111701k8cf8b5p60623a65eb6bda95@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Parag Warudkar <parag.warudkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:40452 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753775AbYHLAlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:41:14 -0400
In-Reply-To: <82e4877d0808111701k8cf8b5p60623a65eb6bda95@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parag Warudkar wrote:
> 
> What output do you see with your patch?

# ip -f inet6 route get fec0::1
unreachable fec0::1 dev lo  table unspec  proto none  src 
2001:1890:1109:a10:218:feff:fe7f:49c8  metric -1  error -101 hoplimit 255

And if I down eth0 I get:

# ip -f inet6 route get fec0::1
unreachable fec0::1 dev lo  table unspec  proto none  src ::1  metric -1 
  error -101 hoplimit 255

This is 2.6.27-rc2, like I said, I"m building a 2.6.24 kernel now.

-Brian
