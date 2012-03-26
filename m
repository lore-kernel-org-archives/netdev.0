From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 4/7] net/mlx4_en: Set max rate-limit for a TC
Date: Mon, 26 Mar 2012 19:00:34 +0200
Message-ID: <CAJZOPZKGJ_nJt92THc+eRGnEXPZG+hX_d2=f56m7gB_Fv8K4Cg@mail.gmail.com>
References: <1332752874-8086-1-git-send-email-amirv@mellanox.com>
	<1332752874-8086-5-git-send-email-amirv@mellanox.com>
	<1332773163.3500.81.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>
To: Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:48541 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932974Ab2CZRAg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 13:00:36 -0400
Received: by lbbgm6 with SMTP id gm6so4133590lbb.19
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 10:00:35 -0700 (PDT)
In-Reply-To: <1332773163.3500.81.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 26, 2012 at 4:46 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
>> We used sysfs since max bw isn't part of the ETS / DCBX NL support, =
and we're
>> open to other suggestions to add generic support for max bw, e.g add=
 call to
>> the DCBX NL API.

> netlink interfaces are generally easily extensible and it doesn't mak=
e
> sense to me to augment such an interface through sysfs. =A0Perhaps yo=
u're
> concerned that netlink extensions won't be supported in older kernel
> versions running your OOT driver? =A0That's unfortunate, but let's no=
t
> standardise an ugly interface based on a temporary problem like that.

As written above, that was done since ratelimit isn't part of ETS, we c=
an
that through netlink extensions that you mentioned, if this is the pref=
fered
way to go, David? Eric? Ben - could you provide pointer to these extens=
ions?

Or.
