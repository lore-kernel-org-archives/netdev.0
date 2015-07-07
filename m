From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: linux-4.2-rc1/samples/bpf/sockex3_kern.c: bad expression ?
Date: Tue, 7 Jul 2015 12:14:38 -0700
Message-ID: <20150707191437.GA6040@Alexeis-MBP.westell.com>
References: <DUB128-W38D412CB6F86AA3D6084F49C920@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexei Starovoitov <ast@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Binderman <dcb314@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34856 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932407AbbGGTOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 15:14:42 -0400
Received: by pdbci14 with SMTP id ci14so130722709pdb.2
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 12:14:42 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <DUB128-W38D412CB6F86AA3D6084F49C920@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 07, 2015 at 11:27:55AM +0000, David Binderman wrote:
> Hello there,
>=20
> [linux-4.2-rc1/samples/bpf/sockex3_kern.c:268]: (style) Expression '(=
X & 0xf0) =3D=3D 0x4' is always false.
>=20
> Source code is
>=20
> =A0=A0 if ((verlen & 0xF0) =3D=3D 4)
>=20
> Maybe
>=20
> =A0=A0 if ((verlen & 0xF0) =3D=3D 0x40)

oops, yes. Could you please send a patch to fix it. Thx
