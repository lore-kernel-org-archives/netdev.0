From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.20.7 TCP cubic (and bic) initial slow start way too slow?
Date: Wed, 13 Jun 2007 00:56:42 -0700 (PDT)
Message-ID: <20070613.005642.85685043.davem@davemloft.net>
References: <20070612.151258.120619253.davem@davemloft.net>
	<20070612171603.47736395@localhost>
	<20070612233814.4b04db2f.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, sangtae.ha@gmail.com,
	rhee@eos.ncsu.edu, rhee@ncsu.edu, netdev@vger.kernel.org
To: billfink@mindspring.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60459
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756059AbXFMH4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 03:56:25 -0400
In-Reply-To: <20070612233814.4b04db2f.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bill Fink <billfink@mindspring.com>
Date: Tue, 12 Jun 2007 23:38:14 -0400

> If there was a benefit, perhaps it would be useful to have a
> per-route option for setting the initial_ssthresh.

We have this per-route setting already, BIC and CUBIC just override it
with their local initial_ssthresh value when that is non-zero.

I wonder how many folks get tripped up by that totally unexpected
behavior.  What's the point of the route metric we've had all of
these years if the congestion control algorithm is just going to
totally ignore it?  That should never be the default behavior.

> OTOH just setting it to zero as a default should also be fine as
> that's the standard Reno behavior.

This is what I'm going to do.

Injong-ssi and Sangtae-ssi have had several weeks to give us final
guidance in this area, we cannot wait forever.
