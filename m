From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Using jiffies for tcp_time_stamp?
Date: Fri, 25 May 2012 17:17:42 +0100
Message-ID: <CAA93jw7MU8PjFk-UX864STSBp2SjjjivmfpRiPhaQ2kxZLu2sA@mail.gmail.com>
References: <CAACrLC39Xdm3vTKUsjz43ZPyEq_vHxR-_Uf56SjSm+kUqxOqZg@mail.gmail.com>
	<CAACrLC2CXU-DNeonWQGJTfX53ssm_asK7WQrFuWRBB77cg-YdA@mail.gmail.com>
	<4FBFAC30.8050508@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-2?Q?Sre=E6ko_Juri=E6=2DKavelj?=
	<srecko.juric-kavelj@fer.hr>, netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:51191 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753985Ab2EYQRp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 12:17:45 -0400
Received: by wibhn6 with SMTP id hn6so1091109wib.1
        for <netdev@vger.kernel.org>; Fri, 25 May 2012 09:17:44 -0700 (PDT)
In-Reply-To: <4FBFAC30.8050508@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 25, 2012 at 4:58 PM, Chris Friesen
<chris.friesen@genband.com> wrote:
> On 05/22/2012 11:21 AM, Sre=C4=87ko Juri=C4=87-Kavelj wrote:
>
>> By looking at the code it's clear that the time stamping is done wit=
h
>> jiffies, and my kernel has CONFIG_HZ=3D100.
>>
>> I understand that this is for performance reasons (and the RTT
>> smoothing filter is implemented with bit shifting operations), but
>> would using a more precise time stamp have significant impact on
>> performance? Since RTT is used to compute RTO, wouldn't there be any
>> benefits of having more accurate estimate of this value?
>
>
> I don't know if it would make any difference to the tcp algorithms, b=
ut
> certainly on some architectures you can get a fast and accurate hardw=
are
> timestamp.

I would be interested in someone doing that experiment in light of the
codel work.
>
> Chris
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.ht=
ml



--=20
Dave T=C3=A4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
http://www.bufferbloat.net
