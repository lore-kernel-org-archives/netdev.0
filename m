From: Fabio Checconi <fchecconi@gmail.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v2)
Date: Wed, 2 Mar 2011 03:06:10 +0100
Message-ID: <20110302020610.GD1005@gandalf.sssup.it>
References: <20110228171738.2cc8c9a0@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms01.sssup.it ([193.205.80.99]:57404 "EHLO sssup.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757201Ab1CBDE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 22:04:28 -0500
Content-Disposition: inline
In-Reply-To: <20110228171738.2cc8c9a0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Mon, Feb 28, 2011 05:17:38PM -0800
>
> This is an implementation of the Quick Fair Queue scheduler developed
> by Fabio Checconi. The same algorithm is already implemented in ipfw
> in FreeBSD. Fabio had an earlier version developed on Linux, I just
> cleaned it up and tested it. All bugs are mine.
> 

  thanks for posting, I'm pretty sure that bugs are more likely to be
ours than yours :)

During the development of the algorithm we used a simple traffic
simulator to verify (informally) the timestamping and the guarantees
provided.  I've tested this version of the code with the simulator and
so far it worked fine, so I think that timestamping and guarantees should
be OK.

Please let us know if we can be of any help,
fabio
