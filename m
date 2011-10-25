From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: make bonding slaves honour master's skb->priority
Date: Tue, 25 Oct 2011 19:22:46 -0400 (EDT)
Message-ID: <20111025.192246.402731945970959971.davem@davemloft.net>
References: <20111025110808.27db8487@asterix.rh>
	<CANP3RGeMbVFf6oL3+9i8h43q1ycdzcA47rNfzeyLWpi8M8ZV5w@mail.gmail.com>
	<7147.1319561135@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zenczykowski@gmail.com, fbl@redhat.com, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753798Ab1JYXWw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2011 19:22:52 -0400
In-Reply-To: <7147.1319561135@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 25 Oct 2011 09:45:35 -0700

> Maciej =AFenczykowski <zenczykowski@gmail.com> wrote:
>=20
>>> I tripped on it few times and never understood why we
>>> were fixing the priority at this point.
>>> thanks,
>>
>>It looks like ancient code, going all the way back to something like
>>Linux 2.4.14 (if I recall my git blame session correctly).
>>I can't think of a good reason for this...
>=20
> 	I believe this line goes back to the beginning, prior to git or
> bk.  The skb->priority probably meant something different than it doe=
s
> today.
>=20
> 	In any event, I'm fine with the code change.  There's still no
> actual log message, but if Davem is ok with that I'm ok with it, give=
n
> the trivial nature of the change.
>=20
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks everyone.
