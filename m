From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Host got crash when guest running netperf client with
 UDP_STREAM protocol with IPV6
Date: Tue, 11 Oct 2011 08:04:51 +0200
Message-ID: <1318313091.2606.4.camel@edumazet-laptop>
References: <4E93A94A.1010001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Qunfang Zhang <qzhang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:53734 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab1JKGE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2011 02:04:56 -0400
Received: by wyg34 with SMTP id 34so6619283wyg.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 23:04:55 -0700 (PDT)
In-Reply-To: <4E93A94A.1010001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 11 octobre 2011 =C3=A0 10:26 +0800, Qunfang Zhang a =C3=A9crit=
 :
>=20
> Hi, guys
>=20
> I found the following bug on RHEL6.2 kernel and after re-test, latest
> stable kernel also has this problem.
> Jiri suggests it would be best to resolve this via upstream as well,
> so I send you the mail.  Thank you.
>=20
> Bug 740465 - Host got crash when guest running netperf client with
> UDP_STREAM protocol with IPV6
> https://bugzilla.redhat.com/show_bug.cgi?id=3D740465
>=20
> For the vmcore log please also find it from the bug attachment.
>=20
>=20
>=20
Isnt it fixed by Jason Wang patch ?

( ipv6: fix NULL dereference in udp6_ufo_fragment() )
