From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer (v4)
Date: Sat, 08 May 2010 08:36:37 +0200
Message-ID: <1273300597.2325.55.camel@edumazet-laptop>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
	 <20100508010108.GA3028@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:37757 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249Ab0EHHo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 May 2010 03:44:57 -0400
Received: by bwz19 with SMTP id 19so932552bwz.21
        for <netdev@vger.kernel.org>; Sat, 08 May 2010 00:44:55 -0700 (PDT)
In-Reply-To: <20100508010108.GA3028@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 07 mai 2010 =C3=A0 21:01 -0400, Neil Horman a =C3=A9crit :
> Hey, Had a moment tonight so I spun version 4 of the patch.
>=20
> Change notes:
> 1) Redid the initialization, in light of Erics clarification.  We ran=
domly seed
> all 32 bits of the rt_genid for a netns, but still just do 256 byte
> modifications on cache invalidations
>=20
> 2) got rid of the dup checking crap.
>=20
>=20
> Summary:
>=20
> A while back there was a discussion regarding the rt_secret_interval =
timer.
> Given that we've had the ability to do emergency route cache rebuilds=
 for awhile
> now, based on a statistical analysis of the various hash chain length=
s in the
> cache, the use of the flush timer is somewhat redundant.  This patch =
removes the
> rt_secret_interval sysctl, allowing us to rely solely on the statisti=
cal
> analysis mechanism to determine the need for route cache flushes.
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Sorry for the confusion Neil, thanks !


