From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 08:11:42 +0000
Message-ID: <201210120811.43290.arnd@arndb.de>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk> <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com> <yw1xtxu1nfsn.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?iso-8859-1?q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	"David Laight" <David.Laight@aculab.com>,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:64425 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675Ab2JLIMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 04:12:03 -0400
In-Reply-To: <yw1xtxu1nfsn.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 October 2012, M=E5ns Rullg=E5rd wrote:
> > But, the IP header is expected to be aligned.
>=20
> Everything tells the compiler the struct is perfectly aligned.  When =
the
> buggy driver passes a misaligned pointer, bad things happen.

Would it be appropriate to add a WARN_ON_ONCE() in the alignment fault =
path
then? If all alignment faults in the kernel are caused by broken driver=
s,
that would at least give us some hope of finding those drivers while at=
 the
same time not causing much overhead in the case where we need to do the
fixup in the meantime.

	Arnd
