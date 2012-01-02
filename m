From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 02 Jan 2012 18:41:25 +0100
Message-ID: <1325526085.18116.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
	 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
	 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
	 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1325523178.18116.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=gA2pd8wJtBRRLSH_MKXOj3_FzfcXg7v705+8w-xdByLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:49386 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654Ab2ABRl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 12:41:28 -0500
Received: by wgbds13 with SMTP id ds13so21740843wgb.1
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 09:41:27 -0800 (PST)
In-Reply-To: <CAL8zT=gA2pd8wJtBRRLSH_MKXOj3_FzfcXg7v705+8w-xdByLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 02 janvier 2012 =C3=A0 18:20 +0100, Jean-Michel Hautbois a =C3=
=A9crit :

> Here we go...
>=20
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
>=20
>  87380  16384  16384    60.01      21.79
>=20
> It is not very good, AFAIK.
> CPU usage is between 17 and 35%.

Ouch...

Better find out what is happening before even starting coding
anything...

checkout "netstat -s" on both sender/receiver
