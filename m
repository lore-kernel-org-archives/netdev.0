From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Mon, 17 Mar 2014 15:17:31 +0200
Message-ID: <20140317131731.GM3200@reaktio.net>
References: <87siqlnol8.fsf@nemi.mork.no>
 <20140314090525.GB3200@reaktio.net>
 <87ob19nndo.fsf@nemi.mork.no>
 <20140314125934.GC3200@reaktio.net>
 <87vbvgnbv3.fsf@nemi.mork.no>
 <20140314142559.GD3200@reaktio.net>
 <87k3btm57a.fsf@nemi.mork.no>
 <20140317115919.GK3200@reaktio.net>
 <20140317124555.GL3200@reaktio.net>
 <87y509kluc.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh06.mail.saunalahti.fi ([62.142.5.116]:44061 "EHLO
	emh06.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756229AbaCQNRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 09:17:33 -0400
Content-Disposition: inline
In-Reply-To: <87y509kluc.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 02:15:23PM +0100, Bj=F8rn Mork wrote:
> Pasi K=E4rkk=E4inen <pasik@iki.fi> writes:
>=20
> > After playing with it for a while I got this:
> >
> > [ 1082.972880] cdc_ncm_setup: huawei_cdc_ncm 3-1:1.1: dwNtbInMaxSiz=
e=3D262144 dwNtbOutMaxSize=3D32768 wNdpOutPayloadRemainder=3D2 wNdpOutD=
ivisor=3D4 wNdpOutAlignment=3D4 wNtbOutMaxDatagrams=3D0 flags=3D0x1f
> > [ 1082.972893] cdc_ncm_setup: huawei_cdc_ncm 3-1:1.1: Using default=
 maximum receive length=3D32768
> > [ 1082.973281] cdc_ncm_setup: huawei_cdc_ncm 3-1:1.1: Setting NTB f=
ormat to 16-bit failed
> >
> > .. which looks to be related..
>=20
> Yes, that is what I expected after thinking long enough to realize th=
at
> I could just read this out of the usbmon dump you provided.
>

:)
=20
> Thanks a lot for all your help providing extremely useful debug info
> here.  This helped fixing (soon, anyway :-) a nasty bug, hitting only=
 a
> few devices.
>=20

No problems. Happy to help to get this device working :)=20

> I still don't know for sure, but I do hope this bug is the real cause=
 of
> the problems you are having.  I'll send you a patch for testing as so=
on
> as it is ready.
>=20

Sure. I'll be happy to test the patch!

>=20
> Bj=F8rn

Thanks,

-- Pasi
