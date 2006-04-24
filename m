From: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Subject: Re: Van Jacobson's net channels and real-time
Date: Mon, 24 Apr 2006 12:59:42 -0400
Message-ID: <Pine.LNX.4.61.0604241254180.24099@chaos.analogic.com>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk> <200604221529.59899.ioe-lkml@rameria.de> <20060422134956.GC6629@wohnheim.fh-wedel.de> <200604230205.33668.ioe-lkml@rameria.de> <444CFFE5.1020509@intel.com>
Reply-To: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ingo Oeser" <ioe-lkml@rameria.de>,
	=?iso-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>,
	"Ingo Oeser" <netdev@axxeo.de>,
	"David S. Miller" <davem@davemloft.net>, <simlo@phys.au.dk>,
	<linux-kernel@vger.kernel.org>, <mingo@elte.hu>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spirit.analogic.com ([204.178.40.4]:49927 "EHLO
	spirit.analogic.com") by vger.kernel.org with ESMTP
	id S1750742AbWDXQ75 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 12:59:57 -0400
In-Reply-To: <444CFFE5.1020509@intel.com>
Content-class: urn:content-classes:message
To: "Auke Kok" <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 24 Apr 2006, Auke Kok wrote:

> Ingo Oeser wrote:
>> On Saturday, 22. April 2006 15:49, J=F6rn Engel wrote:
>>> That was another main point, yes.  And the endpoints should be as
>>> little burden on the bottlenecks as possible.  One bottleneck is th=
e
>>> receive interrupt, which shouldn't wait for cachelines from other c=
pus
>>> too much.
>>
>> Thats right. This will be made a non issue with early demuxing
>> on the NIC and MSI (or was it MSI-X?) which will select
>> the right CPU based on hardware channels.
>
> MSI-X. with MSI you still have only one cpu handling all MSI interrup=
ts and
> that doesn't look any different than ordinary interrupts. MSI-X will =
allow
> much better interrupt handling across several cpu's.
>
> Auke
> -

Message signaled interrupts are just a kudge to save a trace on a
PC board (read make junk cheaper still). They are not faster and
may even be slower. They will not be the salvation of any interrupt
latency problems. The solutions for increasing networking speed,
where the bit-rate on the wire gets close to the bit-rate on the
bus, is to put more and more of the networking code inside the
network board. The CPU get interrupted after most things (like
network handshakes) are complete.

Cheers,
Dick Johnson
Penguin : Linux version 2.6.16.4 on an i686 machine (5592.89 BogoMips).
Warning : 98.36% of all statistics are fiction, book release in April.
_
=1A=04

****************************************************************
The information transmitted in this message is confidential and may be =
privileged.  Any review, retransmission, dissemination, or other use of=
 this information by persons or entities other than the intended recipi=
ent is prohibited.  If you are not the intended recipient, please notif=
y Analogic Corporation immediately - by replying to this message or by =
sending an email to DeliveryErrors@analogic.com - and destroy all copie=
s of this information, including any attachments, without reading or di=
sclosing them.

Thank you.
