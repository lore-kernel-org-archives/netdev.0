From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis
 purpose.
Date: Fri, 18 Mar 2011 07:05:24 +0100
Message-ID: <1300428324.2881.5.camel@edumazet-laptop>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	 <1300351330.10164.712.camel@edumazet-laptop>
	 <AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	 <20110317142030.62af785a@nehalam>
	 <AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44838 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174Ab1CRGF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 02:05:29 -0400
Received: by fxm17 with SMTP id 17so3389673fxm.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 23:05:28 -0700 (PDT)
In-Reply-To: <AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 17 mars 2011 =C3=A0 21:33 -0700, Jerry Chu a =C3=A9crit :

> Yes I'm familiar with ss and how inet_csk_diag_fill() calls into
> tcp_diag_get_info(),..., etc. Like I mentioned previously the netlink
> interface
> requires a new version of reader app (e.g., ss) to ship every time a =
new
> counter is added and exported by the kernel, whereas /proc/net/tcp do=
es
> not have such a problem.
>=20
> Anyway I can add a INET_DIAG_INFO_EXT of some sort to netlink in
> addition to /proc/net/tcp. That's easy to do.
>=20

I suggest adding a getsockopt() or something to gather stats for one
socket. On a loaded machine, /proc/net/tcp is damn slow.

We have TCP_INFO, we could add TCP_INFO_EXT, but taking care of choosin=
g
an interface allowing for extension of the structure.



