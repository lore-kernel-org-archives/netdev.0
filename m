From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next] ethtool: bring back missing comma in netdev_features_strings
Date: Thu, 12 May 2011 13:33:21 +0200
Message-ID: <BANLkTimVw0yGSexP6goH+hTtzkwBudHKTQ@mail.gmail.com>
References: <4DCB94E6.2020407@lastsummer.de> <BANLkTikH2uY_crot1DRBFZv9ifmvPQeRog@mail.gmail.com>
 <4DCBA4C5.5040308@lastsummer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: Franco Fichtner <franco@lastsummer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56240 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381Ab1ELLdl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 07:33:41 -0400
Received: by qwk3 with SMTP id 3so722214qwk.19
        for <netdev@vger.kernel.org>; Thu, 12 May 2011 04:33:41 -0700 (PDT)
In-Reply-To: <4DCBA4C5.5040308@lastsummer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 12 maja 2011 11:13 u=BFytkownik Franco Fichtner
<franco@lastsummer.de> napisa=B3:
> On 12/05/11 10:55, Micha=B3 Miros=B3aw wrote:
>> 2011/5/12 Franco Fichtner <franco@lastsummer.de>:
>>> I found this while skimming through recent net-next patches.
>>> I'm not quite sure if the padding in this struct is correct now.
>> Nice catch. But please send the patch inline instead of as an attach=
ment.
> Thanks, but I have a short question. Are the empty strings in
> this struct really needed?
>
> =A0 =A0 =A0 =A0/* NETIF_F_TSO6 */ =A0 =A0 =A0 =A0 =A0 =A0"tx-tcp6-seg=
mentation",
> =A0 =A0 =A0 =A0/* NETIF_F_FSO */ =A0 =A0 =A0 =A0 =A0 =A0 "tx-fcoe-seg=
mentation",
> =A0 =A0 =A0 =A0"",
> =A0 =A0 =A0 =A0"",
>
> =A0 =A0 =A0 =A0/* NETIF_F_FCOE_CRC */ =A0 =A0 =A0 =A0"tx-checksum-fco=
e-crc",
>
> They seem to have caused this mess in the first place and I would
> think they could be removed entirely.

Mahesh Bandewar tried to do some cleanup in how feature bits are
defined using an enum, but it wasn't completed. If that cleanup was
completed, this array could be initialized using C99 style:

  [NETIF_F_TSO6_BIT] =3D "tx-tcp6-segmentation",

(This has more advantages than pure aesthetics.) For now those empty
strings have to stay, as the array positions are relevant.

Best Regards,
Micha=B3 Miros=B3aw
