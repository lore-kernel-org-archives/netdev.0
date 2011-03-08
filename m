From: Steve.Glendinning@smsc.com
Subject: Re: [Bugme-new] [Bug 30092] New: smsc911x.c drops long packets with VLAN
 tags
Date: Tue, 8 Mar 2011 10:27:08 +0000
Message-ID: <OF5E4EBBD1.3EF03B32-ON8025784D.0039189E-8025784D.003966B6@smsc.com>
References: <bug-30092-10286@https.bugzilla.kernel.org/>	<20110301161547.13480e90.akpm@linux-foundation.org>
	<lnsjv58vl2.fsf@desktop3.csbnet.se> <20110307.123103.115933638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, bugme-daemon@bugzilla.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	weinholt@csbnet.se, Ian.Saturley@smsc.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:58497 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752346Ab1CHKnk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 05:43:40 -0500
In-Reply-To: <20110307.123103.115933638.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Subject: [PATCH] net/smsc911x.c: Set the VLAN1 register to fix VLAN=
=20
MTU problem
> > From: G=F6ran Weinholt <weinholt@csbnet.se>
> >=20
> > The smsc911x driver would drop frames longer than 1518 bytes, which=
 is=20
a
> > problem for networks with VLAN tagging. The VLAN1 tag register is u=
sed
> > to increase the legal frame size to 1522 when a VLAN tag is=20
identified.
> >=20
> > Signed-off-by: G=F6ran Weinholt <weinholt@csbnet.se>
>=20
> Applied, thanks.

Thanks David, I was just about to ack this but you beat me to it :-)

As G=F6ran said, the datasheet is a little vague.  I've checked here, a=
nd=20
there aren't any bad implications of always turning this option on.

Acked-by: Steve Glendinning <steve.glendinning@smsc.com>
