From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276
 problem
Date: Fri, 14 Mar 2014 10:41:59 +0200
Message-ID: <20140314084159.GA3200@reaktio.net>
References: <1383555049-24834-1-git-send-email-bjorn@mork.no>
 <20140313202557.GV3200@reaktio.net>
 <1394746907.15946.8.camel@dcbw.local>
 <20140313220812.GW3200@reaktio.net>
 <20140314075548.GX3200@reaktio.net>
 <87wqfxnppc.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emh02.mail.saunalahti.fi ([62.142.5.108]:49158 "EHLO
	emh02.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755771AbaCNImC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 04:42:02 -0400
Content-Disposition: inline
In-Reply-To: <87wqfxnppc.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 09:34:39AM +0100, Bj=F8rn Mork wrote:
> Pasi K=E4rkk=E4inen <pasik@iki.fi> writes:
> > On Fri, Mar 14, 2014 at 12:08:12AM +0200, Pasi K=E4rkk=E4inen wrote=
:
> >>
> >> I've been using:
> >>=20
> >> ATQ0 V1 E1 S0=3D0
> >> AT^NDISDUP=3D1,1,"internet"
> >> AT^DHCP?
> >>
> >
> > Oh, I forgot to mention.. after I send AT^NDISDUP=3D1,1,"internet" =
I get this:
> >
> > ^NDISSTAT:1,,,"IPV4"
> >
> > .. which to my understanding means it's connected (1=3D=3Dconnected=
).
> > Also sending AT^NDISSTATQRY? results in:
> >
> > ^NDISSTATQRY: 1,,,"IPV4"
>=20
>=20
> What response do you get to the AT^DHCP? request when connected?
>=20

^NDISSTAT:1,,,"IPV4"
^RSSI: 21

<I send: AT^DHCP?>
^DHCP: CCDB080A,F8FFFFFF,C9DB080A,C9DB080A,E67B59C0,E77B59C0,85600,8560=
0


>=20
> Bj=F8rn


-- Pasi
