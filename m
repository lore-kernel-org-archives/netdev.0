From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH net-next] igb: fix stats handling
Date: Wed, 06 Oct 2010 13:36:42 +0200
Message-ID: <1286365002.5138.7.camel@firesoul.comx.local>
References: <20101005141833.20929.10943.stgit@localhost>
	 <1286289703.2796.292.camel@edumazet-laptop>
	 <1286290393.7071.38.camel@firesoul.comx.local>
	 <1286291947.2796.387.camel@edumazet-laptop>
	 <1286312479.2593.35.camel@edumazet-laptop>
	 <Pine.LNX.4.64.1010052313370.30765@ask.diku.dk>
	 <AANLkTi=+rkietX9jAMy5BRVwAENf-mK15py7y+LYQ-XJ@mail.gmail.com>
	 <1286335729.4861.13.camel@edumazet-laptop>
	 <1286339791.4861.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:41446 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753315Ab0JFLgo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 07:36:44 -0400
In-Reply-To: <1286339791.4861.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-10-06 at 06:36 +0200, Eric Dumazet wrote:
> Le mercredi 06 octobre 2010 =C3=A0 05:28 +0200, Eric Dumazet a =C3=A9=
crit :
>=20
> > I'll let Intel guys doing the backporting work, but for old kernels=
,
> > you'll probably need to use "unsigned long" instead of "u64"
> >=20
> > My plan is :
> >=20
> > - Provide 64bit counters even on 32bit arch
> > - with proper synchro (include/linux/u64_stats_sync.h)
> > - Add a spinlock so we can apply Jesper patch.

You have already integrated my patch, so you get my:

Acked-by: Jesper Dangaard Brouer <hawk@comx.dk>

> Here is the net-next-2.6 patch, I am currently enable to test it, the
> dev machine with IGB NIC cannot be restarted until tomorrow, my son
> Nicolas is currently using it ;)
>=20
> Could you and/or Jesper test it, possibly on 32 and 64 bit kernels ?

I could not resist, I have tested the patch, on a 64 bit kernel, it
works :-).  Did some simple test with two while loops running ethtool -=
S
and ifconfig, didn't see any wrong packet counts.

Tested-by: Jesper Dangaard Brouer <hawk@comx.dk>

Now back to moving office ;-)

--=20
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


