From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and coding-style
Date: Sun, 9 Jan 2011 22:32:18 +0100
Message-ID: <201101092232.19171.christoph.paasch@uclouvain.be>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be> <20110109130608.5c7bb4b0.rdunlap@xenotime.net>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110109130608.5c7bb4b0.rdunlap@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Sunday, January 09, 2011 wrote Randy Dunlap:
> On Sun,  9 Jan 2011 21:55:34 +0100 Christoph Paasch wrote:
> If there is something in net/tcp.h that uses data or functions from
> <linux/list.h>, then <linux/list.h> should be #included in net/tcp.h,
> whether some other file pulls it in indirectly or not.
>=20
> etc. etc. etc.
Why?

IMHO I think that it increases compile-time.
Ok, here in that case it only increases it slightly (probably it isn't =
even=20
measurable). But, if *all* the files would be more strict in including,=
 I'm=20
sure that it would make a difference.
The less files you include, the faster the compilation will be.

In net/tcp.h there were even 4 unnecessary included files.

And, then we would also need to include:
net/net_namespace.h (for struct net)

Also, I think that it makes the code more readable and also easier to=20
maintain. The more files we include, the bigger the chance is that we w=
ill end=20
up with plenty of files unnecessarily included, and thus the compile-ti=
me will=20
explode.

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
