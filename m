From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/9] ifb: convert to 64 bit stats
Date: Thu, 09 Jun 2011 05:37:50 +0200
Message-ID: <1307590670.3980.30.camel@edumazet-laptop>
References: <20110609005356.160260858@vyatta.com>
	 <20110609005417.507470402@vyatta.com>
	 <1307590146.3980.28.camel@edumazet-laptop>
	 <20110608203235.2a2be3e4@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38260 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162Ab1FIDhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2011 23:37:55 -0400
Received: by wya21 with SMTP id 21so815741wya.19
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2011 20:37:54 -0700 (PDT)
In-Reply-To: <20110608203235.2a2be3e4@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 08 juin 2011 =C3=A0 20:32 -0700, Stephen Hemminger a =C3=A9=
crit :

> IFB is running in single thread context. Therefore just locking would
> be enough

Yep, that is provided by include/linux/u64_stats_sync.h for free.

As a bonus, no locking on 64bit arches and a clean interface.



