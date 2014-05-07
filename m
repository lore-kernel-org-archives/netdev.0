From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: A reduced Linux network stack for small systems
Date: Wed, 7 May 2014 14:20:47 +0100
Message-ID: <20140507142047.46012957@alan.etchedpixels.co.uk>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
	<063D6719AE5E284EB5DD2968C1650D6D0F70CFB5@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Andi Kleen'" <andi@firstfloor.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tom.zanussi@linux.intel.com" <tom.zanussi@linux.intel.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F70CFB5@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> You may want some size reduction to run in 16MB, but it is not as pro=
blematic
> as running in 2MB.
>=20
> With that little memory I wouldn't want to run anything that relied o=
n
> dynamic memory allocation (after startup) - except for fixed size dat=
a
> buffers.

You mean like =C2=B5httpd 8) Been there, done that and Tom in fact sent=
 me the
patches to port it to Linux from 2.11BSD PDP/11.

You can do a lot in a very small space. Heck you can run a full 2.11BSD
on a PDP/11 in 1MB, including network stack. You used to be able to bui=
ld
a full self hosting Linux 1.x on a 4MB 386.

If you are using glibc and GNU tools it isn't going to work, but long a=
go
tools were written which just did the job they were supposed to do at t=
he
time and were small and tidy. Programmers were expected to use shell
scripts to combine them for harder jobs rather than be the one person a
year who invoked gnu-wibble --format-sideways-while-singing
--tune=3Dwaltzing-matilda

Alan
