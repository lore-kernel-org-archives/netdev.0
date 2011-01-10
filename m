From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and coding-style
Date: Mon, 10 Jan 2011 17:24:45 +0100
Message-ID: <201101101724.46023.christoph.paasch@uclouvain.be>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be> <201101101244.24932.christoph.paasch@uclouvain.be> <20110110075032.e38955ef.rdunlap@xenotime.net>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110110075032.e38955ef.rdunlap@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Monday, January 10, 2011 wrote Randy Dunlap:
> Documentation/SubmitChecklist, #1:
>=20
> 1: If you use a facility then #include the file that defines/declares
>    that facility.  Don't depend on other header files pulling in ones
>    that you use.
Ok, great. That was the answer I was looking for.

So, there is a clear rule that defines the #include-policy.

Now, should the missing #include's be added, or not?

Alexey Dobriyan is against it, as he says in one of his previous mails.
And, I'm nearly sure that the rule is not respected in plenty of other =
files=20
of the Linux Kernel.

Cheers,
Christoph

--
Christoph Paasch
PhD Student

IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://inl.info.ucl.ac.be/mptcp
Universit=E9 Catholique de Louvain

www.rollerbulls.be
--
