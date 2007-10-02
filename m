From: David Miller <davem@davemloft.net>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 15:32:16 -0700 (PDT)
Message-ID: <20071002.153216.82129058.davem@davemloft.net>
References: <20071002212608.GG29944@bitmover.com>
	<20071002.144709.123999983.davem@davemloft.net>
	<4702C37F.4030601@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lm@bitmover.com, torvalds@linux-foundation.org,
	herbert@gondor.apana.org.au, wscott@bitmover.com,
	netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44693
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752082AbXJBWcQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 18:32:16 -0400
In-Reply-To: <4702C37F.4030601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 02 Oct 2007 15:17:35 -0700

> Stranger still, with a mix of a 2.6.23-rc5ish kernel and a net-2.6.24 one 
> (pulled oh middle of last week?) I get link-rate and I see no asymmetry between 
> TCP_STREAM and TCP_MAERTS over an "e1000" link with no switch or tg3 with a 
> ProCurve on my rx2660's.
> 
> I can also run bw_tcp from lmbench 3.0a8 and get 106 MB/s.
> 
> I don't have a netgear switch to try in all this...

I'm starting to have a theory about what the bad case might
be.

A strong sender going to an even stronger receiver which can
pull out packets into the process as fast as they arrive.
This might be part of what keeps the receive window from
growing.
