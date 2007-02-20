From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 14:23:13 +0300
Message-ID: <20070220112312.GA665@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <20070220.021209.39159087.davem@davemloft.net> <20070220103014.GB7237@2ka.mipt.ru> <200702201210.22907.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59834 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932425AbXBTLYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 06:24:35 -0500
Content-Disposition: inline
In-Reply-To: <200702201210.22907.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 12:10:22PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> Please explain why you chose    h = jhash_2words(faddr, laddr, ports);
>         h ^= h >> 16;
>         h ^= h >> 8;
> 
> jhash is very good, no need to try to be smarter, shufling some bytes... and 
> adding artifacts.

If distribution is fair its whift produces still fair distribution.
In the discussion linked at that test I also produced results without
shifts, which were exactly the same.

-- 
	Evgeniy Polyakov
