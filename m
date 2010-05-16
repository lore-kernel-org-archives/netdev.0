From: Michael Smith <michael@hurts.ca>
Subject: Re: Weird TCP retransmit behaviour in recent kernels
Date: Sun, 16 May 2010 12:08:16 -0400 (EDT)
Message-ID: <alpine.LNX.2.00.1005161204380.3517@pentagram.it.hurts.ca>
References: <alpine.LNX.2.00.1005141815560.3517@pentagram.it.hurts.ca> <alpine.DEB.2.00.1005160118240.30522@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="705298730-1436740325-1274026096=:3517"
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.rog.mail.re2.yahoo.com ([68.142.225.204]:28262 "HELO
	smtp106.rog.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752724Ab0EPQIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 12:08:18 -0400
In-Reply-To: <alpine.DEB.2.00.1005160118240.30522@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--705298730-1436740325-1274026096=:3517
Content-Type: TEXT/PLAIN; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sun, 16 May 2010, Ilpo J=E4rvinen wrote:

> On Fri, 14 May 2010, Michael Smith wrote:

>> It seems like when consecutive packets are lost, the SLES11
>> server retransmits the first packet when the timeout fires. The client
>> ACKs, but the server doesn't retransmit the next lost packet; instead,
>> it sends a couple more new packets, which don't get ACKed.

> This is where your problem is, they should get acked in a _compliant_
> network (with duplicate ACKs).

> Some have seen similar phenomena, every time it has been fault in some
> middlebox/peer that does not do what it should. You can disable frto
> using tcp_frto sysctl if you like, however, I disagree with you as I'm
> pretty sure there is some broken middlebox in the network (which is tryin=
g
> to be too intelligent).

Thanks - tcp_frto=3D0 works around the problem here. The network in the=20
middle is provided by a number of other parties, so I can try to point=20
them in the right direction, but unless Microsoft turns on FRTO by default=
=20
sometime soon, I doubt they will have time to care. :)

Mike
--705298730-1436740325-1274026096=:3517--
