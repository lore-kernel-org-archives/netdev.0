From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Socket option to set congestion window
Date: Wed, 26 May 2010 14:08:18 -0700 (PDT)
Message-ID: <20100526.140818.245406045.davem@davemloft.net>
References: <20100525.225236.226781050.davem@davemloft.net>
	<AANLkTinHGMtfw4Oydfgx0w7QLb-HyYSKdI-4smD-BEkq@mail.gmail.com>
	<87fx1e1sat.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	ycheng@google.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44494
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753696Ab0EZVIJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 17:08:09 -0400
In-Reply-To: <87fx1e1sat.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Andi Kleen <andi@firstfloor.org>
Date: Wed, 26 May 2010 19:33:46 +0200

> Tom Herbert <therbert@google.com> writes:
>>>
>> Thanks to NAT, the concept of a network path or even host specific
>> path is a weakened concept.=A0 On the Internet this may be a path
>> characteristic per client, which unfortunately has no visibility in
>> the kernel other than per connection state.=A0 When a single IP addr=
ess
>> may have thousands of hosts behind it, caching TCP parameters for th=
at
>> IP address is implicitly doing a huge aggregation-- probably dicey..=
=2E
>=20
> Yes all of Saudi-Arabia used to be (is?) one IP address...
>=20
> Caching anything per IP is bogus.

And letting the applications choose the CWND is better?!?!

Every single proposal being mentioned in this thread has huge,
obvious, downsides.

Just because there are some cases of people NAT'ing many machines
behind one IP address doesn't mean we kill performance for the rest of
the world (the majority of internet usage btw) by not caching TCP path
characteristics per IP address.

And just because applications open up many sockets to get better TCP
latency and work around per-connection CWND limits DOES NOT mean we
let the application increase the initial CWND so it can abuse this
EVEN MORE and cause EVEN BIGGER problems.

If people have real, sane, ideas about how to attack this problem I am
all ears.  But everything proposed here so far is complete and utter
crap.
