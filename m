From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: Van Jacobson's net channels and real-time
Date: Mon, 24 Apr 2006 09:42:13 -0700
Message-ID: <444CFFE5.1020509@intel.com>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk> <200604221529.59899.ioe-lkml@rameria.de> <20060422134956.GC6629@wohnheim.fh-wedel.de> <200604230205.33668.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>,
	Ingo Oeser <netdev@axxeo.de>,
	"David S. Miller" <davem@davemloft.net>, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:54998 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750897AbWDXQnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 12:43:17 -0400
To: Ingo Oeser <ioe-lkml@rameria.de>
In-Reply-To: <200604230205.33668.ioe-lkml@rameria.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> On Saturday, 22. April 2006 15:49, J=F6rn Engel wrote:
>> That was another main point, yes.  And the endpoints should be as
>> little burden on the bottlenecks as possible.  One bottleneck is the
>> receive interrupt, which shouldn't wait for cachelines from other cp=
us
>> too much.
>=20
> Thats right. This will be made a non issue with early demuxing
> on the NIC and MSI (or was it MSI-X?) which will select
> the right CPU based on hardware channels.

MSI-X. with MSI you still have only one cpu handling all MSI interrupts=
 and=20
that doesn't look any different than ordinary interrupts. MSI-X will al=
low=20
much better interrupt handling across several cpu's.

Auke
