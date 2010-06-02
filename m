From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 17:32:34 +0200
Message-ID: <1275492754.2725.192.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1006011609280.9438@router.home>
	 <1275430054.2638.115.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1006021025200.30182@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52360 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932633Ab0FBPcj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 11:32:39 -0400
Received: by wyi11 with SMTP id 11so1968098wyi.19
        for <netdev@vger.kernel.org>; Wed, 02 Jun 2010 08:32:38 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.00.1006021025200.30182@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 juin 2010 =C3=A0 10:27 -0500, Christoph Lameter a =C3=A9=
crit :

> Yes but they are not increment any counter. If packets are dropped be=
cause
> of the rp_filter setting interfering f.e. then the packets vanish wit=
hout
> any accounting.
>=20

But packets are vanishing either way.

> LINUX_MIB_INROUTEERRORS? Does it mean I can create a series of new
> counters that allow us to diagnose and distinguish all the different
> causes of packet loss? We would love to have that.
>=20

=46or an example, you could take a look at commit 907cdda5205b
(tcp: Add SNMP counter for DEFER_ACCEPT)

Its pretty straigthforward, and wont conflict with monitoring apps.


