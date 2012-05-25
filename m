From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using jiffies for tcp_time_stamp?
Date: Fri, 25 May 2012 21:00:32 +0200
Message-ID: <1337972432.3347.70.camel@edumazet-glaptop>
References: <CAACrLC39Xdm3vTKUsjz43ZPyEq_vHxR-_Uf56SjSm+kUqxOqZg@mail.gmail.com>
	 <CAACrLC2CXU-DNeonWQGJTfX53ssm_asK7WQrFuWRBB77cg-YdA@mail.gmail.com>
	 <4FBFAC30.8050508@genband.com>
	 <CAA93jw7MU8PjFk-UX864STSBp2SjjjivmfpRiPhaQ2kxZLu2sA@mail.gmail.com>
	 <CAACrLC0b5dyjJM=DGf-9nUOwar3O9EVTTR0tvynQj285EDpfwA@mail.gmail.com>
	 <1337964880.3347.52.camel@edumazet-glaptop>
	 <CAACrLC0eVZJdu802Ff4BWRBKuabS=Z-T3WvZCxyqBTem8-n8ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Taht <dave.taht@gmail.com>,
	Chris Friesen <chris.friesen@genband.com>,
	netdev@vger.kernel.org
To: =?UTF-8?Q?Sre=C4=87ko_Juri=C4=87-Kavelj?=
	<srecko.juric-kavelj@fer.hr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49183 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467Ab2EYTAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2012 15:00:37 -0400
Received: by eaak11 with SMTP id k11so319760eaa.19
        for <netdev@vger.kernel.org>; Fri, 25 May 2012 12:00:36 -0700 (PDT)
In-Reply-To: <CAACrLC0eVZJdu802Ff4BWRBKuabS=Z-T3WvZCxyqBTem8-n8ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-25 at 20:35 +0200, Sre=C4=87ko Juri=C4=87-Kavelj wrote:

> From what I've seen in the code, NO_HZ doesn't make jiffies go away,
> it simply doesn't use regular CONFIG_HZ interrupt to update, but
> updates them when has an opportunity?

HZ=3D1000 makes jiffies 10 times more precise, and with NO_HZ, generate=
s
no extra timer interrupts.

This also makes timers workload smoothed, instead of spikes.
