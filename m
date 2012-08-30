From: =?UTF-8?B?Q3Jpc3RpYW4gUm9kcsOtZ3Vleg==?= <crrodriguez@opensuse.org>
Subject: Re: BUG: soft lockup - CPU#6 stuck for 22s! [httpd2-event:15597]
Date: Wed, 29 Aug 2012 23:05:10 -0400
Message-ID: <503ED866.3020609@opensuse.org>
References: <5038215E.60403@opensuse.org> <1345885186.19483.109.camel@edumazet-glaptop> <1345886085.19483.141.camel@edumazet-glaptop> <1345895225.19483.447.camel@edumazet-glaptop> <CADVnQymYXHcqJEgcgH0OHHFfCe6LAMSBZ0E68NWzDZQNTqB+Sg@mail.gmail.com> <1346040367.2420.22.camel@edumazet-glaptop> <CADVnQy=bdHm2jcuReZaxr-qRMRWLDLnVP-jkzBTE-HPZ9FROmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63843 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754024Ab2H3DGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 23:06:34 -0400
Received: by ialo24 with SMTP id o24so2457325ial.19
        for <netdev@vger.kernel.org>; Wed, 29 Aug 2012 20:06:33 -0700 (PDT)
In-Reply-To: <CADVnQy=bdHm2jcuReZaxr-qRMRWLDLnVP-jkzBTE-HPZ9FROmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El mi=C3=A9 29 ago 2012 21:37:46 CLT, Neal Cardwell escribi=C3=B3:

Hi neal, thanks for taking a look at this..

> 1) Are you still seeing this problem in your workload? If so, would
> you have time to try another small patch to add instrumentation to
> track down the cause?

After Eric's patch I no longer see this backtrace or hang, however the=20
machine does
hang apparently for another reason that I have been unable to capture
no clue at all in the logs and the KVM-over-ip video does not respond=20
after hang, needing a reset,
that's strange though, as it is usually able to display kernel messages=
=20
after a crash.

> 2) Do you happen to run with the tcp_mtu_probing sysctl enabled?

   No, sysctl returns : net.ipv4.tcp_mtu_probing =3D 0
