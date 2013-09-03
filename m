From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: VLAN HW accel, performance advantage?
Date: Tue, 3 Sep 2013 20:01:00 +0200
Message-ID: <OF1F55F7C1.0CEB1FB1-ONC1257BDB.0062911D-C1257BDB.0062F868@transmode.se>
References: <OF00E35E7C.7482EC01-ONC1257BDB.00314AD0-C1257BDB.0031F6D0@transmode.se>	 <1378216216.1545.1.camel@bwh-desktop.uk.level5networks.com>
	 <OF0F246C2A.B5DC5CA4-ONC1257BDB.004CA4E6-C1257BDB.004DB31E@transmode.se>
	 <1378219696.1545.9.camel@bwh-desktop.uk.level5networks.com> <1378222150.7360.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:62629 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753910Ab3ICSBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 14:01:03 -0400
In-Reply-To: <1378222150.7360.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 2013/09/03 17:29:10:
> 
> On Tue, 2013-09-03 at 15:48 +0100, Ben Hutchings wrote:
> 
> > GRO should be beneficial for bridges if you have bursty TCP streams. 
It
> > is especially beneficial if you also have TSO on the TX side.
> > 
> > Really you're going to have to try it and run benchmarks with your own
> > hardware.
> 
> Note that ucc_geth does not have GRO support (it calls
> netif_receive_skb())
> 
> It doesnt have RX checksuming either, so having to validate
> tcp checksums (before aggregating them in GRO stack) would hurt if
> packets only have to be forwarded.

Yes, the controller only have IP header checksum. Seems there is little to
gain with HW VLAN support for this controller, maybe when I got some spare 
time
then. :)

Thanks guys

  Jocke
