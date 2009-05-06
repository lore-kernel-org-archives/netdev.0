From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 02/12] fs_enet: Add MPC5121 FEC support.
Date: Wed, 6 May 2009 16:29:59 -0600
Message-ID: <fa686aa40905061529u11b231afle3b5bb10a2334ad0@mail.gmail.com>
References: <1241640919-4650-1-git-send-email-wd@denx.de> <1241640919-4650-3-git-send-email-wd@denx.de>
	<fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.com>
	<20090506220119.7322783420E8@gemini.denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, John Rigby <jrigby@freescale.com>,
	Piotr Ziecik <kosmo@semihalf.com>, netdev@vger.kernel.org,
	John Rigby <jcrigby@gmail.com>, Detlev Zundel <dzu@denx.de>
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:31980 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758239AbZEFWaT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 18:30:19 -0400
Received: by yx-out-2324.google.com with SMTP id 3so233457yxj.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2009 15:30:19 -0700 (PDT)
In-Reply-To: <20090506220119.7322783420E8@gemini.denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 6, 2009 at 4:01 PM, Wolfgang Denk <wd@denx.de> wrote:
> Dear Grant,
>
> in message <fa686aa40905061333q29c263c8p24856c048e30f4d0@mail.gmail.c=
om> you wrote:
>>
> ...
>> > #ifdef CONFIG_FS_ENET_HAS_FEC
>> > +#ifdef CONFIG_FS_ENET_MPC5121_FEC
>> > + =A0 =A0{
>> > + =A0 =A0 =A0 =A0.compatible =3D "fsl,mpc5121-fec",
>> > + =A0 =A0 =A0 =A0.data =3D (void *)&fs_fec_ops,
>> > + =A0 =A0},
>> > +#else
>> > =A0 =A0{
>> > =A0 =A0 =A0 =A0.compatible =3D "fsl,pq1-fec-enet",
>> > =A0 =A0 =A0 =A0.data =3D (void *)&fs_fec_ops,
>> > =A0 =A0},
>> > #endif
>> > +#endif
>>
>> Hmmm. =A0A lot of these #ifdefs in here. =A0Does this have a multipl=
atform
>> impact? =A0Not to mention the fact that it's just plain ugly. =A0:-)
>
> Agreed that it's ugly, but duplicatio9ng the code would have been eve=
n
> worse. I don't think that it has multiplatform - at least not as long
> as you don't ask for one image that runs on 83xx and on 512x.

Actually, I *am* asking for one image that runs on 83xx, 52xx and
521x.  I already can and do build and test a single image which boots
on all my 52xx boards, on my 8349 board, and on my G4 Mac.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
