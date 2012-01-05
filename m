From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Thu, 05 Jan 2012 11:04:51 +0100
Message-ID: <1325757891.2415.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
	 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
	 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
	 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F0382BB.5060601@hp.com>
	 <CAL8zT=iSP+GncMEJ38eaCZ85P-tBDMUjUeaFr-x3j_rksUaK2A@mail.gmail.com>
	 <1325756410.2415.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=jyzV6BwB6Lce0CCi+Z3MuwNsWLw2DQu8HBdm_J8kvArA@mail.gmail.com>
	 <1325757343.2415.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAL8zT=hGnnuXf+cETy9fAeu+aACp2pfL3XfBS_jL_mk38fj4yQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:65164 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754084Ab2AEKEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 05:04:55 -0500
Received: by qats34 with SMTP id s34so9856qat.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 02:04:54 -0800 (PST)
In-Reply-To: <CAL8zT=hGnnuXf+cETy9fAeu+aACp2pfL3XfBS_jL_mk38fj4yQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 10:57 +0100, Jean-Michel Hautbois a =C3=
=A9crit :
>  # netperf -H 192.168.0.1 -c -l 10 -t UDP_STREAM -- -m 1500
> MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to
> 192.168.0.1 (192.168.0.1) port 0 AF_INET
> Socket  Message  Elapsed      Messages                   CPU      Ser=
vice
> Size    Size     Time         Okay Errors   Throughput   Util     Dem=
and
> bytes   bytes    secs            #      #   10^6bits/sec % SU     us/=
KB
>=20
> 106496    1500   10.00       54477      0        0.0     65.34    100=
=2E000
> 1073741824           2.25            0               0.0     65.34   =
 -1.000
>=20

Hmm... this sounds you have half duplex somewhere ?

ethtool eth0   (on both machines)
