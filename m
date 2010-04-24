From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] rps: optimize rps_get_cpu()
Date: Sun, 25 Apr 2010 00:19:27 +0800
Message-ID: <q2i412e6f7f1004240919la9825819i81a4d3063ed781a5@mail.gmail.com>
References: <1272122227-13070-1-git-send-email-xiaosuo@gmail.com>
	<1272125052.8918.18.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:51229 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859Ab0DXQUa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 12:20:30 -0400
Received: by iwn35 with SMTP id 35so6441888iwn.21
        for <netdev@vger.kernel.org>; Sat, 24 Apr 2010 09:20:29 -0700 (PDT)
In-Reply-To: <1272125052.8918.18.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 12:04 AM, jamal <hadi@cyberus.ca> wrote:
>
> By the time you hit this code (at least on machines that make sense f=
or
> RPS), you already have the ethernet header, IP header and transport
> ports in cache, no?
> I think the sport << 16 shifting is avoided - but i dont think theres
> any effect on mem access.

Maybe I have used the wrong word. Sorry. If the ports are already in
cache, the new code has only one cache access for ports, and the later
operations are in registers.


--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
