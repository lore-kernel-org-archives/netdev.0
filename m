From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next v6 0/3] The huawei_cdc_ncm driver / E3276 problem
Date: Mon, 17 Mar 2014 14:15:23 +0100
Message-ID: <87y509kluc.fsf@nemi.mork.no>
References: <87wqfxnppc.fsf@nemi.mork.no> <20140314084159.GA3200@reaktio.net>
	<87siqlnol8.fsf@nemi.mork.no> <20140314090525.GB3200@reaktio.net>
	<87ob19nndo.fsf@nemi.mork.no> <20140314125934.GC3200@reaktio.net>
	<87vbvgnbv3.fsf@nemi.mork.no> <20140314142559.GD3200@reaktio.net>
	<87k3btm57a.fsf@nemi.mork.no> <20140317115919.GK3200@reaktio.net>
	<20140317124555.GL3200@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dan Williams <dcbw@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, Enrico Mioso <mrkiko.rs@gmail.com>,
	Oliver Neukum <oliver@neukum.org>
To: Pasi =?utf-8?B?S8Okcmtrw6RpbmVu?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34940 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932514AbaCQNPq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 09:15:46 -0400
In-Reply-To: <20140317124555.GL3200@reaktio.net> ("Pasi =?utf-8?Q?K=C3=A4r?=
 =?utf-8?Q?kk=C3=A4inen=22's?= message
	of "Mon, 17 Mar 2014 14:45:55 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pasi K=C3=A4rkk=C3=A4inen <pasik@iki.fi> writes:

> After playing with it for a while I got this:
>
> [ 1082.972880] cdc_ncm_setup: huawei_cdc_ncm 3-1:1.1: dwNtbInMaxSize=3D=
262144 dwNtbOutMaxSize=3D32768 wNdpOutPayloadRemainder=3D2 wNdpOutDivis=
or=3D4 wNdpOutAlignment=3D4 wNtbOutMaxDatagrams=3D0 flags=3D0x1f
> [ 1082.972893] cdc_ncm_setup: huawei_cdc_ncm 3-1:1.1: Using default m=
aximum receive length=3D32768
> [ 1082.973281] cdc_ncm_setup: huawei_cdc_ncm 3-1:1.1: Setting NTB for=
mat to 16-bit failed
>
> .. which looks to be related..

Yes, that is what I expected after thinking long enough to realize that
I could just read this out of the usbmon dump you provided.

Thanks a lot for all your help providing extremely useful debug info
here.  This helped fixing (soon, anyway :-) a nasty bug, hitting only a
few devices.

I still don't know for sure, but I do hope this bug is the real cause o=
f
the problems you are having.  I'll send you a patch for testing as soon
as it is ready.


Bj=C3=B8rn
