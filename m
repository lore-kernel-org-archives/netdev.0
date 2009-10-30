From: Patrick McHardy <kaber@trash.net>
Subject: Re: Connection tracking and vlan
Date: Fri, 30 Oct 2009 17:26:11 +0100
Message-ID: <4AEB13A3.50402@trash.net>
References: <20091030152054.GA7936@gondor.apana.org.au> <4AEB06E6.6020206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Adayadil Thomas <adayadil.thomas@gmail.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48187 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932572AbZJ3Q0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 12:26:15 -0400
In-Reply-To: <4AEB06E6.6020206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Herbert Xu a =E9crit :
>> Adayadil Thomas <adayadil.thomas@gmail.com> wrote:
>>> If two connections have same 5 tuple, src ip, dst ip, src port, dst
>>> port, protocol(tcp/udp)
>>> but on different vlans (different vlan id), does the conntrack sepa=
rate these ?
>> Probably not.  Patrick, can you confirm this?

Yes, you are right.

> Very strange, this question about vlan looks like discussion we had
> yesterday (or the day before...) about interfaces (versus packet defr=
agmentation)

Indeed, we did have that discussion a couple of years ago. IIRC
Rusty also suggested to add the interface to the defragmentation
key to avoid having fragments from different interfaces being
reassembled since iptables interface matches will only match on
the interface of the first fragment.
