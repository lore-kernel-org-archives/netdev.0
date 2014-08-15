From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Fri, 15 Aug 2014 12:10:29 -0700
Message-ID: <53EE5B25.3040206@intel.com>
References: <53ECFDAB.5010701@intel.com>	<1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>	<53ED4354.9090904@intel.com>	<20140814.162024.2218312002979492106.davem@davemloft.net>	<53EE4023.6080902@intel.com> <CA+mtBx_aEe6SvWV6tfqzGWcPvVM+FE6kbnyFE5FbECU9HN7EXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:19242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbaHOTKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 15:10:53 -0400
In-Reply-To: <CA+mtBx_aEe6SvWV6tfqzGWcPvVM+FE6kbnyFE5FbECU9HN7EXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/15/2014 11:49 AM, Tom Herbert wrote:
> Alex, I tried to repro your problem running your script (on bnx2x).
> Didn't see see the issue and in fact ip_dest_check did not appear in
> top perf functions on perf. I assume this is more related to the
> steering configuration rather than the device (although flow director
> might be a fundamental difference).
> 

So the original script I put out had a typo.  It was supposed to run all
60 at the same time, not one at a time.  So make sure you add an
ampersand to the end of the netperf command line if you run the test so
that it is 60 at once, not 60 in series.

Also one other thing I had to do was disable tcp_autocork.  Without that
the test is a large packets test instead of a small packet test.

Thanks,

Alex
