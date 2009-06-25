From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: PATCH: ipv6: avoid wraparound for expired lifetimes
Date: Thu, 25 Jun 2009 12:35:22 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0906251227370.1447@melkinkari.cs.Helsinki.FI>
References: <20090625073943.GO21357@jayr.de> <Pine.LNX.4.64.0906251135410.917@melkinkari.cs.Helsinki.FI>
 <20090625090603.GP21357@jayr.de>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243445-273107291-1245922522=:1447"
Cc: Netdev <netdev@vger.kernel.org>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58983 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbZFYJfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 05:35:20 -0400
In-Reply-To: <20090625090603.GP21357@jayr.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243445-273107291-1245922522=:1447
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT

On Thu, 25 Jun 2009, Jens Rosenboom wrote:

> On Thu, Jun 25, 2009 at 11:40:19AM +0300, Ilpo Järvinen wrote:
> > On Thu, 25 Jun 2009, Jens Rosenboom wrote:
> > 
> > > If the valid or preferred lifetime for an address expires, the kernel
> > > shows huge values for these due to a counter wrap,
> > 
> > I suspect we have plenty of potentially counter-wrapped printouts all 
> > around the kernel. So you're fixing just a tip of the iceberg.
> 
> So are you implying that because I don't fix all of them at once, I
> shouldn't bother to start at all?

I meant that fixing this place alone won't magically fix the rest which 
suffer from the very same symptoms even though you might have never seen 
the other cases in practice (that's why I used the iceberg parable).

I was thinking that some kind of helper would be useful for annotating 
what is happening and changing the other places too (not necessarily in 
the very same patch).

-- 
 i.
---696243445-273107291-1245922522=:1447--
