From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TSO trimming question
Date: Fri, 21 Dec 2007 11:28:37 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712211127460.31652@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
 <20071219.235450.170670042.davem@davemloft.net>
 <Pine.LNX.4.64.0712201253400.31652@kivilampi-30.cs.helsinki.fi>
 <20071220.035621.147230372.davem@davemloft.net> <20071221030648.389669c4.billfink@mindspring.com>
 <Pine.LNX.4.64.0712211055550.31652@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-855619397-1198229317=:31652"
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	John Heffner <jheffner@psc.edu>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56465 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753399AbXLUJ2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:28:39 -0500
In-Reply-To: <Pine.LNX.4.64.0712211055550.31652@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-855619397-1198229317=:31652
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 21 Dec 2007, Ilpo Järvinen wrote:

> On Fri, 21 Dec 2007, Bill Fink wrote:
> 
> > If so it seems like a lot of unnecessary
> > work just to avoid a 1 in 4 billion event, since it's my understanding
> > that the whole tcp_tso_should_defer function is just an optimization
> > and not a criticality to the proper functioning of TCP, especially
> > considering it hasn't even been executing at all up to now.
> 
> It would still be good to not return 1 in that case we didn't flag the 
> deferral, how about adding one additional tick (+comment) in the zero 
> case making tso_deferred == 0 again unambiguously defined, e.g.:
> 
> 	tp->tso_deferred = min_t(u32, jiffies, 1);

Blah, max_t of course :-).


-- 
 i.
---696243703-855619397-1198229317=:31652--
