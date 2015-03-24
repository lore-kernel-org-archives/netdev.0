From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Tue, 24 Mar 2015 14:21:49 +0100
Message-ID: <551164ED.5000907@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable
Cc: Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>,
 Jhristoph Lameter <cl@linux.com>,
 Jekka Enberg <penberg@kernel.org>, Javid Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Jndrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
 linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org,
 Jeff Dike <jdike@addtoit.com>,
 Rusty Russell <rusty@rustcorp.com.au>,
 Mathieu Lacage <mathieu.lacage@gmail.com>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, linux-arch@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Am 24.03.2015 um 14:10 schrieb Hajime Tazaki:
 > =3D=3D More information =3D=3D
>=20
> The crucial difference between UML (user-mode linux) and this approach
> is that we allow multiple network stack instances to co-exist within a
> single process with dlmopen(3) like linking for easy debugging.

Is this the only difference?
We already have arch/um, why do you need arch/lib/ then?
My point is, can't you merge your arch/lib into the existing arch/um stuf=
f?
>From a very rough look your arch/lib seems like a micro UML.

BTW: There was already an idea for having UML as regular library.
See: http://user-mode-linux.sourceforge.net/old/projects.html
"UML as a normal userspace library"

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
