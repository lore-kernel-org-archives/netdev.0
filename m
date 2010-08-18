From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] vxge: Implement 64bit stats
Date: Wed, 18 Aug 2010 17:28:43 +0200
Message-ID: <1282145323.2194.105.camel@edumazet-laptop>
References: <1282138974.2194.83.camel@edumazet-laptop>
	 <20100818152531.GB9202@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: Jon Mason <jon.mason@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59442 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715Ab0HRP2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 11:28:51 -0400
Received: by wyb32 with SMTP id 32so902551wyb.19
        for <netdev@vger.kernel.org>; Wed, 18 Aug 2010 08:28:50 -0700 (PDT)
In-Reply-To: <20100818152531.GB9202@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 ao=C3=BBt 2010 =C3=A0 10:25 -0500, Jon Mason a =C3=A9cri=
t :
> On Wed, Aug 18, 2010 at 06:42:54AM -0700, Eric Dumazet wrote:
> > vxge_get_stats() is racy, since it clears a block of memory (net_st=
ats)
> > possibly still used by other cpus.
> >=20
> > We can update this driver to full 64bit stats, since ndo_get_stats6=
4()
> > provides a private block to store results, and driver maintains 64b=
it
> > counters already.
> >=20
> > We also remove net_stats field from struct vxge_sw_stats
>=20
> It looks sane.  Assuming you have not tested it already, I'll give it=
 a
> quick sanity check.

I did not test it, I would be grateful if you can do this ;)

Thanks


