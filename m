From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH 0/2] Tracepoint for tcp retransmission
Date: Sun, 18 Dec 2011 01:49:44 +0100
Message-ID: <20111218004944.GB14903@hell>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFA64F@USINDEVS02.corp.hds.com>
 <5f654c7d-f18e-4d70-8830-a3e31b8f5f4a@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Satoru Moriya <satoru.moriya@hds.com>, nhorman@tuxdriver.com,
	davem@davemloft.net, tgraf@infradead.org,
	Seiji Aguchi <seiji.aguchi@hds.com>,
	dle-develop@lists.sourceforge.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:53230 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751058Ab1LRAts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2011 19:49:48 -0500
Content-Disposition: inline
In-Reply-To: <5f654c7d-f18e-4d70-8830-a3e31b8f5f4a@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Sometimes network packets are dropped for some reason. In enterprise
> systems which require strict RAS functionality, we must know the
> reason why it happened and explain it to our customers even if using
> TCP. When we investigate the incidents, at first we try to find out
> whether the problem is in the server(kernel, application) or else
> (router, hub etc). And next we try to find out which layer
> (application/middleware/kernel(IP/TCP/UDP/..)etc.) the problem
> occurs.

For the first question tcpdump may the right tool. For the later systemtap can
be used. I mean we now have the possibility to instrument the kernel at runtime,
without bloating the source. Anyway: is 63e03724b51 not suitable to gather the
required information easily?

Hagen
