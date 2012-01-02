From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 02 Jan 2012 17:52:58 +0100
Message-ID: <1325523178.18116.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
	 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
	 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
	 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:51177 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415Ab2ABQxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 11:53:01 -0500
Received: by wibhm6 with SMTP id hm6so8510786wib.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 08:53:00 -0800 (PST)
In-Reply-To: <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 17:52 +0100, Eric Dumazet a =C3=A9crit =
:
> Le lundi 02 janvier 2012 =C3=A0 17:40 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>=20
> > Mmmh, using netperf you would like to know what the client (my ARM
> > board) can do ?
> > How would you test it ? I can have an ARM board on one side, and th=
e
> > x86 on the other...
> >=20
>=20
> x86> netserver &
> arm> netperf -H <arm_ip_address> -l 60 -t TCP_STREAM
>=20

well it should be :

arm> netperf -H <x86_ip_address> -l 60 -t TCP_STREAM
