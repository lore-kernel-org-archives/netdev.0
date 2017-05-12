From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Queries regarding TAP interface
Date: Fri, 12 May 2017 08:52:29 -0700
Message-ID: <20170512085229.3cecd2d1@xeon-e3>
References: <C7C039BE-EDC9-4E82-BC66-EEDE814F9E56@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kashyap, Saurav" <Saurav.Kashyap@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33870 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757351AbdELPwc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 11:52:32 -0400
Received: by mail-pg0-f48.google.com with SMTP id u28so32138637pgn.1
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 08:52:32 -0700 (PDT)
In-Reply-To: <C7C039BE-EDC9-4E82-BC66-EEDE814F9E56@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 12 May 2017 05:02:37 +0000
"Kashyap, Saurav" <Saurav.Kashyap@cavium.com> wrote:

> Hi,
>=20
> I am using upstream kernel 4.11.0 and base is RHEL 7.2. I am playing arou=
nd with TAP devices and created it using following commands
> =3D=3D=3D=3D=3D=3D=3D
> ip tuntap add tap10 mode tap
> ip addr add 172.28.12.1/24 dev tap10
> ip link set tap10 up
> ethtool -s tap10 msglvl 1
> =3D=3D=3D=3D=3D=3D=3D
>=20
> I enabled debug in driver and also added some prints in tun_net_xmit func=
tion. I tried to ping using tap10 but I don=E2=80=99t see request reaching =
driver. I also tried to create a bridge using brctl and link with physical =
ethernet interface but it didn=E2=80=99t work.
>=20
> Second experiment I did was to create two tap device on same system and t=
ry pinging one from another, that also didn=E2=80=99t worked.=20
> I have following queries
> 1) Is I am missing something?=20
> 2) Is is possible to hook my own tx/rx to that tap device, so that data p=
ackets actually goes on wire?
> 3) Does DHCP works with tap devices?
>=20
>=20
> Thanks,
> ~Saurav
>=20

Don't you need an application reading/writing the tap device?
The carrier state of tap device is up/down based on whether the correspondi=
ng tap device is open
