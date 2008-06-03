From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Wed, 4 Jun 2008 01:10:03 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806040104340.3474@wrl-59.cs.helsinki.fi>
References: <20080603094057.GA29480@elte.hu> <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1731635768-1212531003=:3474"
Cc: mingo@elte.hu, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru,
	mcmanus@ducksong.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52811 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbYFCWKF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 18:10:05 -0400
In-Reply-To: <20080603.150344.145518113.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1731635768-1212531003=:3474
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Tue, 3 Jun 2008, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Wed, 4 Jun 2008 01:01:25 +0300 (EEST)
> 
> > On Wed, 4 Jun 2008, Ilpo Järvinen wrote:
> > 
> > > ...I couldn't immediately find anything obviously wrong with those changes 
> > > but the patch below might be worth of a try (without the revert of 
> > > course). If it ever spits out that WARN_ON for you, we were playing with 
> > > fire too much and it's better to return on the safe side there...
> > 
> > 
> > > [PATCH] tcp DEFER_ACCEPT: see if header prediction got turned on
> > > 
> > > If header prediction is turned on under some circumstances,
> > > DA can deadlock though I have great trouble in figuring out
> > 
> > ...Nah, keepalive timer would then eventually kill it then, so no
> > deadlock seems possible through that one.
> 
> Keepalive is very long, it might still "seem" like a deadlock for
> someone without much patience :-)

Sure, but I think Ingo kept it once hang for hours, ~8h or so...
...Though I'm not sure if that qualifies as a proof of Ingo's patience 
but rather shows his willingness to help solving the matter... ;-)

-- 
 i.
---696208474-1731635768-1212531003=:3474--
