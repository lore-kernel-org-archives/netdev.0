From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: get beyond 1Gbps with pktgen  on 10Gb nic?
Date: Tue, 11 May 2010 14:35:25 +0100
Message-ID: <1273584925.2107.6.camel@achroite.uk.solarflarecom.com>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D752C7@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jon Zhou <Jon.Zhou@jdsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:21505 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756924Ab0EKNfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 09:35:30 -0400
In-Reply-To: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497D752C7@MILEXCH2.ds.jdsu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-05-11 at 06:13 -0700, Jon Zhou wrote:
> hi there:
> 
> anyone can get beyond 1Gbps with pktgen or other SW traffic generator with 10Gb nic(intel 82599 or BCM 57711)?
> found that some one had met similar situation with broadcom 10G nic but no solution yet

I don't know about those specific controllers, but you should be able to
achieve close to 10G line rate with netperf's TCP_STREAM on any recent
PC server.  UDP throughput tends to be poorer as there is less support
for offloading segmentation and reassembly.  Performance may also be
constrained by PCI Express bandwidth (you need a real 8-lane slot) and
memory bandwidth (a single memory bank may not be enough).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

