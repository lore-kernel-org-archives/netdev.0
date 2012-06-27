From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 15:21:53 -0700 (PDT)
Message-ID: <20120627.152153.75362722222316911.davem@davemloft.net>
References: <1340823810.26242.81.camel@edumazet-glaptop>
	<4FEB6B64.5060708@hp.com>
	<1340829541.26242.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, tparkin@katalix.com, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, jchapman@katalix.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47603 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768Ab2F0WVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 18:21:54 -0400
In-Reply-To: <1340829541.26242.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Jun 2012 22:39:01 +0200

> In 2012 or 2013, 64bits kernels are the norm, and 32bit the exception.
> 
> Should we add complex code to l2tp just for being able to run it on
> 32bit kernels with 64bit stats ?
> 
> Considering this code is buggy at the v1 & v2, I am really wondering.
> 
> All sane SNMP applications are ready to cope with 32bits counters
> wrapping.
> 
> Machines that could wrap the 32bit counter several times per second are
> probably running on 64bit kernels.
> 
> Also percpu stats are overkill unless a device is really meant to be
> used in // by many cpus.

I agree with Eric on all counts.
