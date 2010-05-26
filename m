From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Wed, 26 May 2010 19:33:46 +0200
Message-ID: <87fx1e1sat.fsf@basil.nowhere.org>
References: <alpine.DEB.1.00.1005252157150.27170@pokey.mtv.corp.google.com>
	<20100525220858.1071f238@nehalam>
	<20100525.225236.226781050.davem@davemloft.net>
	<AANLkTinHGMtfw4Oydfgx0w7QLb-HyYSKdI-4smD-BEkq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, ycheng@google.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39022 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757234Ab0EZRdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 13:33:52 -0400
In-Reply-To: <AANLkTinHGMtfw4Oydfgx0w7QLb-HyYSKdI-4smD-BEkq@mail.gmail.com> (Tom Herbert's message of "Wed\, 26 May 2010 00\:06\:35 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <therbert@google.com> writes:
>>
> Thanks to NAT, the concept of a network path or even host specific
> path is a weakened concept.=A0 On the Internet this may be a path
> characteristic per client, which unfortunately has no visibility in
> the kernel other than per connection state.=A0 When a single IP addre=
ss
> may have thousands of hosts behind it, caching TCP parameters for tha=
t
> IP address is implicitly doing a huge aggregation-- probably dicey...

Yes all of Saudi-Arabia used to be (is?) one IP address...

Caching anything per IP is bogus.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
