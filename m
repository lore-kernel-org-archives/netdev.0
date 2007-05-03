From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: finding your own dead "CONFIG_" variables
Date: Thu, 3 May 2007 12:02:56 +0200
Message-ID: <200705031202.56805.arnd@arndb.de>
References: <Pine.LNX.4.64.0705030400120.20539@localhost.localdomain> <a781481a0705030237l7d636b55t93f2ee5151cd7709@mail.gmail.com> <Pine.LNX.4.64.0705030546310.29962@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Satyam Sharma <satyam.sharma@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:54429 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161458AbXECKDH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 06:03:07 -0400
In-Reply-To: <Pine.LNX.4.64.0705030546310.29962@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 03 May 2007, Robert P. J. Day wrote:
> > Suggest: configfiles=3D$(find . -name 'Kconfig*' -or -name '*defcon=
fig*')
> >
> > Some CONFIG_ options exist that are not declared anywhere in the
> > Kconfig files but defined directly in the arch/.../*defconfig*
> > files.
>=20
> it's my understanding that entries in any defconfig files are
> *automatically* pruned at some point once a CONFIG_ variable no longe=
r
> exists in any Kconfig file, so i'm not going to be touching those
> files. =A0also, adding that extra check wouldn't add anything useful =
to
> the output.


An interesting category would be a symbol that is

- used in a source file
- defined in an old defconfig
- not present in any Kconfig* file

If any of these exist, I would consider them _worse_ than the ones
found by your initial script, because some functionality that once
was there has been recently removed.

	Arnd <><
