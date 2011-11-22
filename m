From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Get TOS from IP header
Date: Tue, 22 Nov 2011 06:31:00 +0100
Message-ID: <1321939860.27077.10.camel@edumazet-laptop>
References: <A2354B6A9F807641B21EEABD666ECEEA01F7DDEC@XMB-BGL-416.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Naveen B N (nbn)" <nbn@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:38910 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815Ab1KVFbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 00:31:03 -0500
Received: by wwe3 with SMTP id 3so6676861wwe.1
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 21:31:02 -0800 (PST)
In-Reply-To: <A2354B6A9F807641B21EEABD666ECEEA01F7DDEC@XMB-BGL-416.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 novembre 2011 =C3=A0 07:06 +0530, Naveen B N (nbn) a =C3=A9=
crit :
> Hi All,
>=20
> I want  to get the TOS field content from IP header at=20
> my application which is using SCTP protocol.
> I know that it can be done by Using RAW socket but=20
> There is a over head of implementing the sctp at the=20
> Application layer .=20
> Is there a better way of getting a TOS field filled
> Which we received from IP header.
>=20
> I taught of adding code in kernel to recognize a socket option at the=
 kernel,
> If this option is set just and get TOS contents in receive .
>=20
> Please let me know if this is the way to go about it or is there=20
> A better way to achieve the same .
>=20

I believe SCTP is not yet described in "man 7 ip", but since its
obviously an IP protocol, all things described in this man page should
work.

       IP_RECVTOS (since Linux 2.2)
              If enabled the IP_TOS ancillary message is passed with  i=
ncoming  packets.
              It contains a byte which specifies the Type of Service/Pr=
ecedence field of
              the packet header.  Expects a boolean integer flag.
