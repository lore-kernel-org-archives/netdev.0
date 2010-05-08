From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: remove ip_rt_secret timer (v4)
Date: Sat, 08 May 2010 01:58:05 -0700 (PDT)
Message-ID: <20100508.015805.223472011.davem@davemloft.net>
References: <20100506171639.GA5063@hmsreliant.think-freely.org>
	<20100508010108.GA3028@localhost.localdomain>
	<1273300597.2325.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60854
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751362Ab0EHI57 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 May 2010 04:57:59 -0400
In-Reply-To: <1273300597.2325.55.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 08 May 2010 08:36:37 +0200

> Le vendredi 07 mai 2010 =E0 21:01 -0400, Neil Horman a =E9crit :
>> A while back there was a discussion regarding the rt_secret_interval=
 timer.
>> Given that we've had the ability to do emergency route cache rebuild=
s for awhile
>> now, based on a statistical analysis of the various hash chain lengt=
hs in the
>> cache, the use of the flush timer is somewhat redundant.  This patch=
 removes the
>> rt_secret_interval sysctl, allowing us to rely solely on the statist=
ical
>> analysis mechanism to determine the need for route cache flushes.
>>=20
>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>>=20
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks guys!
