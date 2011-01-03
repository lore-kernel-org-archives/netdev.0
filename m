From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atl1: fix oops when changing tx/rx ring params
Date: Mon, 03 Jan 2011 11:04:52 -0800 (PST)
Message-ID: <20110103.110452.39176099.davem@davemloft.net>
References: <20110101090212.7149010d@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, stable@kernel.org, jussuf@linux.ee,
	chris.snook@gmail.com, kronos.it@gmail.com, Xiong.Huang@Atheros.com
To: jcliburn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751285Ab1ACTEV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 14:04:21 -0500
In-Reply-To: <20110101090212.7149010d@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "J. K. Cliburn" <jcliburn@gmail.com>
Date: Sat, 1 Jan 2011 09:02:12 -0600

> Commit 3f5a2a713aad28480d86b0add00c68484b54febc zeroes out the statis=
tics
> message block (SMB) and coalescing message block (CMB) when adapter r=
ing
> resources are freed.  This is desirable behavior, but, as a side effe=
ct,
> the commit leads to an oops when atl1_set_ringparam() attempts to alt=
er
> the number of rx or tx elements in the ring buffer (by using ethtool
> -G, for example).  We don't want SMB or CMB to change during this
> operation.
>=20
> Modify atl1_set_ringparam() to preserve SMB and CMB when changing rin=
g
> parameters.
>=20
> Cc: stable@kernel.org
> Signed-off-by: Jay Cliburn <jcliburn@gmail.com>
> Reported-by: T=F5nu Raitviir <jussuf@linux.ee>

I'll apply this, thanks Jay.
