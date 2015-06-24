From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: merge window freeze
Date: Wed, 24 Jun 2015 16:14:19 +0300
Message-ID: <73579E83-D190-41C0-BDFC-24C16F862BBE@cumulusnetworks.com>
References: <20150624.025328.682044271321726878.davem@davemloft.net> <EC3F09A3-8B3D-4ABD-B94D-1A36D13DF09A@cumulusnetworks.com> <20150624.054134.167274466460545100.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:38630 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbbFXNOW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 09:14:22 -0400
Received: by wibdq8 with SMTP id dq8so46305451wib.1
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2015 06:14:21 -0700 (PDT)
In-Reply-To: <20150624.054134.167274466460545100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Jun 24, 2015, at 3:41 PM, David Miller <davem@davemloft.net> wrote=
:
>=20
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Date: Wed, 24 Jun 2015 13:25:47 +0300
>=20
>> I noticed that both of my bridge patches are marked with =E2=80=9CCh=
anges Requested=E2=80=9D, but
>> there was no feedback why and also the first one:
>> "bridge: multicast: add a comment to br_port_state_selection about b=
locking state=E2=80=9D
>> was ACKed and in the second one our discussion with Toshiaki
>> was about a possible bug that=E2=80=99s not related to the patch.=20
>> Could you please tell me what I have to change in them ?
>>=20
>> Patch links:
>> [1] https://patchwork.ozlabs.org/patch/487591/
>> [2] https://patchwork.ozlabs.org/patch/487608/
>>=20
>=20
> Indeed, I misread the feedback on patch #2.
>=20
> Series applied, thanks.

Thanks Dave. I had a scalability concern with patch 2 and vlan ranges, =
but I=E2=80=99ll
keep testing and if I hit, or anyone else hits, an issue I=E2=80=99ll w=
orkout a fix.

Cheers,
 Nik
