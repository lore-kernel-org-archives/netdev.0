From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 21:42:13 +0100
Message-ID: <1415997733.15154.62.camel@localhost>
References: <1415978022.15154.31.camel@localhost>
	 <1415979181.17262.45.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1415979978.15154.41.camel@localhost>
	 <20141114.133829.1437047454714311242.davem@davemloft.net>
	 <CAHA+R7NKrwE7F4k4wiaZRJ67QAhB9bUe8SdyuT8Ky3-wAou6cA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, jay.vosburgh@canonical.com,
	discuss@openvswitch.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:44502 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754377AbaKNUmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 15:42:16 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 1EFBE20D16
	for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 15:42:16 -0500 (EST)
In-Reply-To: <CAHA+R7NKrwE7F4k4wiaZRJ67QAhB9bUe8SdyuT8Ky3-wAou6cA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fr, 2014-11-14 at 11:02 -0800, Cong Wang wrote:
> 
> I am wondering, compare with alternative call, how slower is just
> testing
> cpu_has_xmm4_2?

I can test, but cpu_has_xmm4_2 expands into quite some code. I don't
know if indirect function call or a test of this flag is faster. I'll
test this.

Bye,
Hannes
