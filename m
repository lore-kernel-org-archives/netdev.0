From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis
 purpose.
Date: Sat, 19 Mar 2011 06:02:40 +0100
Message-ID: <1300510960.2831.2.camel@edumazet-laptop>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	 <1300351330.10164.712.camel@edumazet-laptop>
	 <AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	 <20110317142030.62af785a@nehalam>
	 <AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
	 <1300428324.2881.5.camel@edumazet-laptop>
	 <AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46676 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837Ab1CSFCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 01:02:46 -0400
Received: by wwa36 with SMTP id 36so5614801wwa.1
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 22:02:45 -0700 (PDT)
In-Reply-To: <AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 mars 2011 =C3=A0 21:33 -0700, Jerry Chu a =C3=A9crit :

> I'm well aware of the past, hideous O(n**2) problem of reading
> /proc/net/tcp but I
> thought the problem has been fixed by Tom Herbert a while back, no?
> (See http://marc.info/?l=3Dlinux-netdev&m=3D127588123429437&w=3D2)
>=20

O(N) is still too slow, to gather stats for your socket, if you want to
gather stats once per second for example.

AFAIK, I am not sure we want to allow any user to access all these data
for all tcp sockets on the machine. This might have security impacts.



