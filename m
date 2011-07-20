From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in
 ndo_start_xmit methods
Date: Wed, 20 Jul 2011 06:24:15 +0200
Message-ID: <1311135855.3113.66.camel@edumazet-laptop>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>
	 <1311105738.3113.11.camel@edumazet-laptop>
	 <20110719202922.GA2352@minipsycho>
	 <1311108107.3113.22.camel@edumazet-laptop>
	 <20110720001904.GA1992@neilslaptop.think-freely.org>
	 <1311122593.3113.46.camel@edumazet-laptop>
	 <4E2626E1.6030005@candelatech.com>
	 <20110720020737.GB2692@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57718 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab1GTEYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 00:24:22 -0400
Received: by wyg8 with SMTP id 8so3213742wyg.19
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2011 21:24:20 -0700 (PDT)
In-Reply-To: <20110720020737.GB2692@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 juillet 2011 =C3=A0 22:07 -0400, Neil Horman a =C3=A9crit :
> >=20
> I think this is a good idea.  It lets pktgen dynamically make the clo=
ne/share
> decision dynamically and only impacts performance for those systems.
>=20

Just let pktgen refuse to use clone_skb command for these devices.

At that point, an userland application is going to be faster and more
flexible than pktgen.

So when I said "remove pktgen" from distro it was not a joke.
Maybe its time to admit pktgen has to be removed from kernel sources.

$ wc net/core/pktgen.c
 3788 10881 92771 net/core/pktgen.c

Hmmm, 3788 lines, patched 180 times for a thing that only sends UDP
frames...



