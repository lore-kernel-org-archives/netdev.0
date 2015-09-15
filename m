From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: kernel panic in pppoe_release
Date: Tue, 15 Sep 2015 20:49:59 +0200
Message-ID: <20150915184959.GA2869@alphalink.fr>
References: <006f01d0e67c$c3d53f10$4b7fbd30$@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Murat Sezgin <msezgin@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:50967 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751070AbbIOSuF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 14:50:05 -0400
Content-Disposition: inline
In-Reply-To: <006f01d0e67c$c3d53f10$4b7fbd30$@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 03, 2015 at 12:14:32PM -0700, Murat Sezgin wrote:
> I just wonder , if the
> proposed patch by Denys Fedoryshchenko, which is below, fixes this is=
sue
> completely.
>=20
> =A0=A0=A0=A0=A0=A0=A0 pppox_unbind_sock(sk);
> =A0=A0=A0=A0=A0=A0=A0 +/* Signal the death of the socket. */
> =A0=A0=A0=A0=A0=A0=A0 +sk->sk_state =3D PPPOX_DEAD;
>=20
> Do you have a conclusion on this bug? Is it safe to get this patch al=
ong
> with the other workqueue patches?
>
You might want to check my recent reply in the original thread:
https://marc.info/?l=3Dlinux-netdev&m=3D144190062507458&w=3D2
