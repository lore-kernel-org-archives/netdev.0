From: Jasper Spaans <spaans@fox-it.com>
Subject: Re: bridging + load balancing bonding
Date: Fri, 23 Oct 2009 11:51:37 +0200
Message-ID: <20091023095137.GA22424@spaans.fox.local>
References: <20091022122339.GA20148@spaans.fox.local> <4AE07D3C.3040702@gmail.com> <20091023083851.GA18457@spaans.fox.local> <4AE16F83.7080400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.fox-it.com ([82.94.91.210]:29299 "EHLO mail2.fox-it.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751431AbZJWJvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2009 05:51:38 -0400
Content-Disposition: inline
In-Reply-To: <4AE16F83.7080400@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 23, 2009 at 10:55:31AM +0200, Eric Dumazet wrote:

> Dont you think special attention is needed for multicast/broadcast trafic
> (they should be sent to both IDS) ?

Not really -- AFAIK we're currently not using the information encapsulated
in broadcast traffic to judge the unicast packets. Besides, we're
aggregating the results from the IDSes, so it shouldn't matter on which node
a packet is processed.

But if the need arises, this could be added quite easily to the code.

Jasper
-- 
Fox-IT Experts in IT Security!
T: +31 (0) 15 284 79 99
KvK Haaglanden 27301624
