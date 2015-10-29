From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: Re: [BUG] Any-IP IPv6 support broken
Date: Thu, 29 Oct 2015 18:58:47 +0000
Message-ID: <E3F3A24A-F483-4026-97E5-B49F65AD2493@gmail.com>
References: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com> <1446143957.486796.423892137.12302CDB@webmail.messagingengine.com>
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35502 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbbJ2S6u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 14:58:50 -0400
Received: by pasz6 with SMTP id z6so48448683pas.2
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 11:58:50 -0700 (PDT)
In-Reply-To: <1446143957.486796.423892137.12302CDB@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 29 Oct 2015, at 18:39, Hannes Frederic Sowa <hannes@stressinduktio=
n.org> wrote:
>=20
> Try the loopback interface:
>=20
> ip -6 route add local abcd:abcd:abcd:abcd::/64 dev *lo*
>=20
> Otherwise packets should end up in neighbor subsystem and you don't w=
ant
> that, still. ;)
>=20

Thanks for the reply.

I know it=E2=80=99s working on the lo interface, but unluckily I need i=
t on
other interfaces (and aliasing lo is not an option).

Moreover:
- the IPv6 patch explicitly refers to the possibility to do this with
  eth0 interface (i.e. it's not a lo-only feature)
- should it be consistent with the IPv4 behaviour? (or maybe it's not
  supposed to work even with IPv4 addresses, and so this is a bug)


thank you,

Gilberto.