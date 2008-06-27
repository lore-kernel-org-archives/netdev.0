From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 8139too: some style cleanups
Date: Fri, 27 Jun 2008 02:09:43 -0400
Message-ID: <48648427.8000606@pobox.com>
References: <4853BB62.1060109@freemail.hu> <4853C8AD.9020407@s5r6.in-berlin.de> <48541165.7050304@freemail.hu> <485421C1.8010102@s5r6.in-berlin.de> <4854C9BF.8040900@freemail.hu> <4854CA3E.60208@freemail.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
	David Newall <davidn@davidnewall.com>, netdev@vger.kernel.org,
	Trivial Patch Monkey <trivial@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?N=E9meth_M=E1rton?= <nm127@freemail.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41248 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757862AbYF0GJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 02:09:56 -0400
In-Reply-To: <4854CA3E.60208@freemail.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

N=E9meth M=E1rton wrote:
> From: M=E1rton N=E9meth <nm127@freemail.hu>
>=20
> Clean up the following errors and warnings reported by checkpatch.pl:
>  + ERROR: Macros with complex values should be enclosed in parenthesi=
s
>  + WARNING: __func__ should be used instead of gcc specific __FUNCTIO=
N__
>  + WARNING: plain inline is preferred over __inline__
>  + WARNING: Use #include <linux/io.h> instead of <asm/io.h>
>  + WARNING: Use #include <linux/uaccess.h> instead of <asm/uaccess.h>
>=20
> The changes were verified with by comparing the "objdump -d 8139too.k=
o"
> output which is exactly the same for the old and new version in case =
of
> config CONFIG_8139TOO=3Dm, CONFIG_8139TOO_PIO=3Dn, CONFIG_8139TOO_TUN=
E_TWISTER=3Dn,
> CONFIG_8139TOO_8129=3Dn, CONFIG_8139_OLD_RX_RESET=3Dn.
> Software versions used: gcc 4.2.3, objdump 2.18.0.20080103, on elf32-=
i386.
>=20
> Signed-off-by: M=E1rton N=E9meth <nm127@freemail.hu>

applied, thanks for whittling down the changes to this set


