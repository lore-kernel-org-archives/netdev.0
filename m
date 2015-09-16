From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] solos-pci: Increase headroom on received packets
Date: Wed, 16 Sep 2015 06:26:52 -0700
Message-ID: <1442410012.4116.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442399145.131189.56.camel@infradead.org>
	 <1442400813.4116.48.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1442403300.131189.73.camel@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, simon@fire.lp0.eu, guy@traverse.com.au,
	linux-atm-general@lists.sourceforge.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34655 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbbIPN0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 09:26:54 -0400
Received: by padhy16 with SMTP id hy16so209695922pad.1
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 06:26:54 -0700 (PDT)
In-Reply-To: <1442403300.131189.73.camel@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-09-16 at 12:35 +0100, David Woodhouse wrote:
> A comment in include/linux/skbuff.h says that:
>=20
>  * Various parts of the networking layer expect at least 32 bytes of
>  * headroom, you should not reduce this.
>=20
> This was demonstrated by a panic when handling fragmented IPv6 packet=
s:
> http://marc.info/?l=3Dlinux-netdev&m=3D144236093519172&w=3D2
>=20
> It's not entirely clear if that comment is still valid =E2=80=94 and =
if it is,
> perhaps netif_rx() ought to be enforcing it with a warning.
>=20
> But either way, it is rather stupid from a performance point of view
> for us to be receiving packets into a buffer which doesn't have enoug=
h
> room to prepend an Ethernet header =E2=80=94 it means that *every* in=
coming
> packet is going to be need to be reallocated. So let's fix that.
>=20
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> ---

LGTM

Acked-by: Eric Dumazet <edumazet@google.com>
