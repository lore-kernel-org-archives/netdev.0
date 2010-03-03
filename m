From: Alexander Zimmermann <Alexander.Zimmermann@nets.rwth-aachen.de>
Subject: Re: TCP Appropriate Byte Counting per default off
Date: Wed, 03 Mar 2010 10:33:31 +0100
Message-ID: <5779FE7B-8E6B-4E67-892D-3D29DD233FEC@nets.rwth-aachen.de>
References: <A7D42088-84DC-4991-A8AD-E4000B2974DA@nets.rwth-aachen.de>
 <alpine.DEB.2.00.1003031035370.10775@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:65090 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755238Ab0CCJdg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 04:33:36 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KYP0061K97YPN50@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 03 Mar 2010 10:33:34 +0100 (CET)
Received: from miami.nets.rwth-aachen.de ([unknown] [137.226.12.180])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0KYP00CX997YQP20@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Wed, 03 Mar 2010 10:33:34 +0100 (CET)
In-reply-to: <alpine.DEB.2.00.1003031035370.10775@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Am 03.03.2010 um 09:48 schrieb Ilpo J=E4rvinen:

> On Wed, 3 Mar 2010, Alexander Zimmermann wrote:
>=20
>> Hi David, hi Ilpo,
>>=20
>> I wonder why ABC is off per default? What are the reasons?
>> Should we turn it on per default?
>>=20
>> From algorithmic point of view I see no flaws just
>> benefits.
>>=20
>> With RFC5681 ABC is recommended.
>> OSX uses ABC per default.
>=20
> As Alexey once put it, ABC is very BSD specific algorithm.
>=20
> Out of two goals of ABC, protection against split ACKs is achieved in=
=20
> Linux by other means (see tcp_clean_rtx_queue and flags it gives to=20
> elsewhere). Thus, you can kind of think that we do APC already :-). T=
he=20
> other part, faster increase during slow start, isn't currently done t=
hough=20
> it would be relatively simple to implement (I think I even have some,=
=20
> possibly unfinished, patch to do that lying around somewhere I wrote=20
> someday).

Related to that is a scenario that I have in mind: reverse path reorder=
ing.
With ABC we are more robust, ie, open cwnd as normal during SS=20

>=20
> ABC is not that necessary when window is counted in packets. And besi=
des=20
> that, it was found to somewhat hurt small segment flows. There are so=
me=20
> messages in archives in the timeframe ABC was disabled (plus there mi=
ght=20
> have been some even older than that).
>=20
> --=20
> i.

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22220
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//

