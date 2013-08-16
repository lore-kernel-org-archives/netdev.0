From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: Re: [PATCH][net-next] gianfar: Add backwards compatible Single Queue
 mode polling
Date: Fri, 16 Aug 2013 13:54:56 +0200
Message-ID: <20130816115456.GA16387@lutz.bln.innominate.local>
References: <CALG0vJtYfhJOMMU1rgDV8TYgkm3MJh2iibqmAJsj3nxbegBWEQ@mail.gmail.com>
 <1370884788-4862-1-git-send-email-claudiu.manoil@freescale.com>
 <CALG0vJtQkM65kr2-u5G578uzAFeCk5=bkKNU5BaBheXTHmc7+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	netdev@vger.kernel.org
To: Michael Guntsche <michael.guntsche@it-loops.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host2.bln.innominate.com ([77.245.32.75]:48767 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104Ab3HPLy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 07:54:58 -0400
Content-Disposition: inline
In-Reply-To: <CALG0vJtQkM65kr2-u5G578uzAFeCk5=bkKNU5BaBheXTHmc7+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 10, 2013 at 07:35:38PM +0200, Michael Guntsche wrote:
> Hello Claudiu,
>=20
> On Mon, Jun 10, 2013 at 7:19 PM, Claudiu Manoil
> <claudiu.manoil@freescale.com> wrote:
> > Older Single Queue (SQ_SG_MODE) devices like TSEC (i.e. mpc83xx)
> > don't feature the frame receive indication bits (RXF) in RSTAT.
> > For these and for the rest of the SQ_SG_MODE devices, provide the
> > appropiate polling routine that handles a single pair of Rx/Tx
> > BD rings, removing the overhead incurred by the multiple queues/
> > multiple interrupt group devices (veTSEC/ eTSEC2.0 devices).
> > So this is primarily a fix for the TSEC devices.
> >
> > Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> > ---
> >  drivers/net/ethernet/freescale/gianfar.c | 51 ++++++++++++++++++++=
++++++++++--
> >  1 file changed, 49 insertions(+), 2 deletions(-)
> >
> <snip>
> I can confirm that this fixes the problem for my TSEC based board.

I need this fix for 3.10.7 as well, so this seems to be stable-stuff.

Best regards,
	Lutz
--=20
Dr.-Ing. Lutz J=E4nicke
CTO
Innominate Security Technologies AG  /protecting industrial networks/
tel: +49.30.921028-200
fax: +49.30.921028-020
Rudower Chaussee 13
D-12489 Berlin, Germany
www.innominate.com

Register Court: AG Charlottenburg, HR B 81603
Management Board: Dirk Seewald
Chairman of the Supervisory Board: Christoph Leifer
