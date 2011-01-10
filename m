From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and coding-style
Date: Mon, 10 Jan 2011 12:44:24 +0100
Message-ID: <201101101244.24932.christoph.paasch@uclouvain.be>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be> <1294614389.2823.35.camel@localhost> <AANLkTik7mug7j=VLz80DX_hJokeO3=ie+KRcMViSL4kB@mail.gmail.com>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Randy Dunlap <rdunlap@xenotime.net>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTik7mug7j=VLz80DX_hJokeO3=ie+KRcMViSL4kB@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday, January 10, 2011 wrote Alexey Dobriyan:
> >> linux/percpu_counter.h (needed for percpu_counter_sum_positive)
> >=20
> > Yes.
>=20
> Currently code compiles fine, so necessary headers are in place,
> so simply adding new headers doesn't help anything.

I totally agree with you.
However we need a consistent coding style.

Or we just include the minimum necessary headers (as originally propose=
d by=20
me).
Or we include every header whose structs/functions are referenced.

In my opinion the current "mixed" state is not ok, because some include=
s are=20
there because there *are* references (even if these includes could be o=
mitted,=20
e.g., linux/list.h).
Other includes (like linux/percpu_counter.h) are not there, because the=
y are=20
indirectly included by another header and thus the code compiles. Even =
if=20
there are references.
And there are no rules/guidelines to identify the headers that should b=
e=20
included and those that should not.

Regards,
Christoph

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
