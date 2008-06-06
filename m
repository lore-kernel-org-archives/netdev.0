From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Fri, 6 Jun 2008 14:23:58 -0700
Message-ID: <20080606142358.5af75c32@infradead.org>
References: <20080603.150344.145518113.davem@davemloft.net>
	<Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi>
	<20080605142244.GA19216@elte.hu>
	<Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
	<Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi>
	<1212708571.19522.10.camel@tng>
	<Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi>
	<1212772293.23706.22.camel@tng>
	<20080606173339.GA30894@elte.hu>
	<Pine.LNX.4.64.0806062037240.9424@wrl-59.cs.helsinki.fi>
	<20080606183926.GB12651@elte.hu>
	<1212782937.23706.46.camel@tng>
	<Pine.LNX.4.64.0806062314420.9424@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McManus <mcmanus@ducksong.com>,
	Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVu?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59253 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbYFFVYR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 17:24:17 -0400
In-Reply-To: <Pine.LNX.4.64.0806062314420.9424@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 7 Jun 2008 00:12:55 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> Arjan, can you please check if your workload uses setsockopt=20
> TCP_DEFER_ACCEPT for the LISTENing socket? ...If not, then your case
> is different from Ingo's.

at this point the observed hung I had seems to be the app doing
something bad (it's the app that hung) so for now please disregard my
previous comments on this topic.

>=20
>=20


--=20
If you want to reach me at my work email, use arjan@linux.intel.com
=46or development, discussion and tips for power savings,=20
visit http://www.lesswatts.org
