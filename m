From: Donald Becker <becker@scyld.com>
Subject: Re: ADMtek AN983B (DEC Tulip compatible) nic problem (fix included)
Date: Fri, 26 Apr 2002 13:28:07 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.33.0204261322340.1031-100000@presario>
References: <ID4.44-02041a1214070.60af-crelm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: =?iso-8859-1?Q?Kurt_Sch=E4big?= <kurt@crelm.de>
In-Reply-To: <ID4.44-02041a1214070.60af-crelm>
List-Id: netdev.vger.kernel.org

On Fri, 26 Apr 2002, Kurt Sch=E4big wrote:

> The Problem:
> The driver module for the DEC Tulip compatible nic does not recognize=
 the
> ADMtek AN938B network controller, although it should.
> Neither does the v2.4 kernel module, nor does v2.5. The vendor says
> version 2.0.x kernels would have worked, but I did not test it.

The 9511 support was added to the tulip driver in v92n 11/3/2000, but t=
he
tulip driver in the kernel does not have most of the improvements of th=
e
past few years.

Use the driver at
   http://www.scyld.com/network/tulip.html
      ftp://www.scyld.com/pub/network/tulip.c

--=20
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993

