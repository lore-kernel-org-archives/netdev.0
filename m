From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Sat, 7 Jun 2008 00:28:01 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806070027200.9424@wrl-59.cs.helsinki.fi>
References: <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi> <20080605142244.GA19216@elte.hu>
 <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi> <1212708571.19522.10.camel@tng>
 <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi> <1212772293.23706.22.camel@tng>
 <20080606173339.GA30894@elte.hu> <Pine.LNX.4.64.0806062037240.9424@wrl-59.cs.helsinki.fi>
 <20080606183926.GB12651@elte.hu> <1212782937.23706.46.camel@tng>
 <Pine.LNX.4.64.0806062314420.9424@wrl-59.cs.helsinki.fi>
 <20080606142358.5af75c32@infradead.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1269415095-1212787681=:9424"
Cc: Patrick McManus <mcmanus@ducksong.com>,
	Ingo Molnar <mingo@elte.hu>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38711 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbYFFV2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 17:28:05 -0400
In-Reply-To: <20080606142358.5af75c32@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1269415095-1212787681=:9424
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 6 Jun 2008, Arjan van de Ven wrote:

> On Sat, 7 Jun 2008 00:12:55 +0300 (EEST)
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> wrote:
> > Arjan, can you please check if your workload uses setsockopt 
> > TCP_DEFER_ACCEPT for the LISTENing socket? ...If not, then your case
> > is different from Ingo's.
> 
> at this point the observed hung I had seems to be the app doing
> something bad (it's the app that hung) so for now please disregard my
> previous comments on this topic.

...Ok, thanks for letting us know.

-- 
 i.
---696208474-1269415095-1212787681=:9424--
