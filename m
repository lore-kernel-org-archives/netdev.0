From: Remi Denis-Courmont <rdenis@simphalempin.com>
Subject: Re: [RFC] [DCCP]: Deprecate =?UTF-8?Q?SOCK=5FDCCP=20in=20favour=20of=20SO?=
 =?UTF-8?Q?CK=5FDGRAM?=
Date: Tue, 13 May 2008 14:53:59 +0200
Message-ID: <48a00ddc692de4b7b71273614e61ab17@chewa.net>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Arnaldo <acme@redhat.com>
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:57319 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754929AbYEMMyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 08:54:00 -0400
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 13 May 2008 08:28:53 +0100, Gerrit Renker <gerrit@erg.abdn.ac.u=
k>=0D
wrote:=0D
> There is an API and an address resolution problem involved in specify=
ing=0D
a=0D
> separate/distinct socket type `SOCK_DCCP'.=0D
(...)=0D
> Having also seen the work-arounds in programs that other people wrote=
,=0D
> I believe that the above change will make it in the long term easier =
for=0D
> people to write DCCP-enabled applications.=0D
=0D
DCCP clearly fails the POSIX definition of SOCK_DGRAM in different ways=
=2E=0D
=0D
I think this is not a good idea.=0D
=0D
> It also relieves the libc writers from having to support another sock=
et=0D
> type.=0D
=0D
As long as SOCK_DCCP-or-whatever is not automatically selected when=0D
ai_socktype is nul, this should be both easy to implement in libc *and*=
=0D
backward compatible (applications will not try to use DCCP implicitly).=
=0D
=0D
> A quick look at SCTP shows that they also did not introduce new socke=
t=0D
> types, relying on the existing SOCK_STREAM/SOCK_SEQPACKET ones.=0D
=0D
But they follow the semantics for them.=0D
=0D
> It might be still early enough to resolve this, before it is widely u=
sed=0D
> and can then only be supported via work-arounds.=0D
> =0D
> I can't see a disadvantage here and the only work required is to upda=
te=0D
> that=0D
> datagram-based not automatically means connection-less.=0D
> =0D
> Is there support for this change or are there reasons to keep SOCK_DC=
CP?=0D
=0D
Maybe the name SOCK_DCCP sucks, but I think DCCP needs a "new" socket t=
ype=0D
anyway.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net

