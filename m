From: Wolfgang Walter <linux@stwm.de>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Tue, 22 Oct 2013 21:07:41 +0200
Message-ID: <3928724.bDaZagpRh6@h2o.as.studentenwerk.mhn.de>
References: <3244031.uQGDddGTLF@h2o.as.studentenwerk.mhn.de> <20131001222002.GL10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:44589 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753537Ab3JVTHn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Oct 2013 15:07:43 -0400
In-Reply-To: <20131001222002.GL10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 2. Oktober 2013, 00:20:02 schrieb Hannes Frederic Sowa:
> On Tue, Oct 01, 2013 at 06:39:32PM +0200, Wolfgang Walter wrote:
> > All network traffic over the router become slow and sluggish. If on=
e pings
> > the router there is a packet loss. After about 2 minutes the traffi=
c
> > completely stalls for about 1 minute. Then it works again as in the
> > beginning to then stall again. And so on.
>=20
> Maybe dropwatch can give a first hint?
>=20

I finally found the problem:

In 3.10.x and 3.11.x the value of /proc/sys/net/ipv4/xfrm4_gc_thresh is=
 1024.

It is much higher in 3.4.x. If I increase this value in 3.10.x to the o=
ne I=20
see on 3.4.x all works fine with 3.10.x

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
