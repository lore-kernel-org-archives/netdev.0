From: Richard Weinberger <richard@nod.at>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
Date: Fri, 27 Mar 2015 10:21:59 +0100
Message-ID: <55152137.20405@nod.at>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at>	<m2bnjhcevt.wl@sfc.wide.ad.jp>	<55133BAF.30301@nod.at>	<m2h9t7bubh.wl@wide.ad.jp>	<5514560A.7040707@nod.at> <m28uejaqyn.wl@wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net,
 cl@linux.com, penberg@kernel.org, rientjes@google.com,
 iamjoonsoo.kim@lge.com, akpm@linux-foundation.org,
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com,
 rusty@rustcorp.com.au, mathieu.lacage@gmail.com
To: Hajime Tazaki <tazaki@wide.ad.jp>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <m28uejaqyn.wl@wide.ad.jp>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Am 27.03.2015 um 07:34 schrieb Hajime Tazaki:
>>> it (arch/lib) is a hardware-independent architecture which
>>> provides necessary features to the remainder of kernel code,
>>> isn't it ?
>>
>> The stuff in arch/ is the code to glue the kernel to
>> a specific piece of hardware.
>> Your code does something between. You duplicate kernel core features
>> to make a specific piece of code work in userland.
>=20
> indeed, 'something between' would be an appropriate word.

Just an idea popping out of my head...

What about putting libos into tools/testing/ and make it much more generi=
c and framework alike.
With more generic I mean that libos could be a stubbing framework for the=
 kernel.
i.e. you specify the subsystem you want to test/stub and the framework he=
lps you doing so.
A lot of the stubs you're placing in arch/lib could be auto-generated as =
the
vast majority of all kernel methods you stub are no-ops which call only l=
ib_assert(false).

Using that approach only very few kernel core components have to be dupli=
cated and
actually implemented by hand.
Hence, less maintenance overhead and libos is not broken all the time.

What do you think?

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
