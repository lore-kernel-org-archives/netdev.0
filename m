From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PROBLEM] Bonding driver in linux-2.6.21-rc6-mm1
Date: Sat, 28 Apr 2007 14:31:02 -0700
Message-ID: <20070428143102.f39299b5.akpm@linux-foundation.org>
References: <200704262058.33087.ve@vetienne.net>
	<200704272205.29131.ve@vetienne.net>
	<20070427153237.03f3b59c.akpm@linux-foundation.org>
	<200704282237.42753.ve@vetienne.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Vincent ETIENNE <ve@vetienne.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:56546 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1030848AbXD1VbH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 17:31:07 -0400
In-Reply-To: <200704282237.42753.ve@vetienne.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 28 Apr 2007 22:37:42 +0200 Vincent ETIENNE <ve@vetienne.net> wr=
ote:

> Le Saturday 28 April 2007 00:32:37 Andrew Morton, vous avez =E9crit=A0=
:
> > On Fri, 27 Apr 2007 22:05:28 +0200
> >
>=20
> > because we thought we'd fixed the rtnl_lock() problems in 2.6.21-rc=
7-mm2.
> > Are you sure that log is from 2.6.21-rc7-mm2?
>=20
>=20
> Yes. I have retested it another time ( for adding the small usb debug=
=20
> message ) and get the same message a new time.
>=20
> Maybe a tiny difference : only eth0 was setup during boot ( bond0 and=
 eth1 was=20
> not setup - volontary  - to avoid problem that could interfere with u=
sb ).=20
> Ony after having done my usb test, i have stopped the eth0, setup bon=
d=20
> interface and restart bond interface and got the same problem with th=
e same=20
> back trace.

OK, thanks.

> Is there anything i can do to get you more precise information ?

I guess if you could provide us with your .config and a step-by-step re=
cipe
which developers should use to reproduce the problem then we should be =
able
to fix this pretty easily when someone finds the time to do so.

