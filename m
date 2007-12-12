From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: 2.6.24-rc4-mm1
Date: Wed, 12 Dec 2007 20:21:25 +0100
Message-ID: <476034B5.80106@fr.ibm.com>
References: <20071204211701.994dfce6.akpm@linux-foundation.org> <47579DD9.9030909@reub.net> <20071205233504.67366c5b.akpm@linux-foundation.org> <Pine.LNX.4.64.0712101136190.18529@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Reuben Farrelly <reuben-linuxkernel@reub.net>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:32220 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758091AbXLLTVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 14:21:30 -0500
In-Reply-To: <Pine.LNX.4.64.0712101136190.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> On Wed, 5 Dec 2007, Andrew Morton wrote:
>=20
>> On Thu, 06 Dec 2007 17:59:37 +1100 Reuben Farrelly <reuben-linuxkern=
el@reub.net> wrote:
>>
>>> This non fatal oops which I have just noticed may be related to thi=
s change then=20
>>> - certainly looks networking related.
>> yep, but it isn't e1000.  It's core TCP.
>>
>>> WARNING: at net/ipv4/tcp_input.c:2518 tcp_fastretrans_alert()
>>> Pid: 0, comm: swapper Not tainted 2.6.24-rc4-mm1 #1
>> Ilpo, Reuben's kernel is talking to you ;)
>=20
> ...Please try the patch below. Andrew, this probably fixes your probl=
em=20
> (the packets <=3D tp->packets_out) as well.

nah. I got the WARNINGs again with this patch.

C.
=20
> Dave, please include this one to net-2.6.25.
>=20
>=20

