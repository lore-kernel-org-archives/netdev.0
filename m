From: David Miller <davem@davemloft.net>
Subject: Re: Extensible hashing and RCU
Date: Thu, 22 Feb 2007 03:07:55 -0800 (PST)
Message-ID: <20070222.030755.130841135.davem@davemloft.net>
References: <f2b55d220702211315h1266d25el4a0f46c4fb65e12a@mail.gmail.com>
	<20070222.010638.27784211.davem@davemloft.net>
	<f2b55d220702220300t4734dd9bxb97f8f63724817f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, dada1@cosmosbay.com, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: medwards.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54883
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1945964AbXBVLIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:08:09 -0500
In-Reply-To: <f2b55d220702220300t4734dd9bxb97f8f63724817f9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael K. Edwards" <medwards.linux@gmail.com>
Date: Thu, 22 Feb 2007 03:00:32 -0800

> Besides, RCUing a hash of any sort sounds like a nightmare, whereas
> something like a splay tree is reputed to be very straightforward to
> make "persistent" in the functional-programming sense.  I haven't
> coded that one myself but surely it's in the current edition of Knuth.

Knuth tends to be thorough, yet archaic. :-)

> You are much better off obtaining all per-flow state with a
> single data structure lookup.  It would be kind of nice if state for
> other layers like IPSec and NAT could live there too.

This is the eventual idea.

> By the way, are these flows unidirectional or bidirectional?

The entries created by Robert's TRASH are unidirectional, they have to
be because the path from remote to localhost is different than the
path from localhost to remote :-)

But we don't need to do a socket demux on packet output, we just
need a plain route (+ firewall, IPSEC, etc.) destination cache
entry for that.
