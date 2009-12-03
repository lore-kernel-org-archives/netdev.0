From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Thu, 03 Dec 2009 15:07:44 +0100
Message-ID: <1259849264.13245.3.camel@nienna.balabit>
References: <1259585129.3992.13.camel@nienna.balabit>
	 <1259589577.873.30.camel@bigi> <1259674488.3168.45.camel@bigi>
	 <20091202.223117.228943068.davem@davemloft.net>
	 <1259848398.3766.43.camel@bigi>  <4B17C346.3000906@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	hidden@sch.bme.hu, aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:34202 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755266AbZLCOHl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 09:07:41 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 9935811E18F
	for <netdev@vger.kernel.org>; Thu,  3 Dec 2009 15:07:45 +0100 (CET)
In-Reply-To: <4B17C346.3000906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, 2009-12-03 at 14:55 +0100, Patrick McHardy wrote:
> jamal wrote:
> > BTW, it should be noted that the change from Patrick to fib_validate
> > which allows to accept local routes from will also solve this problem.
> > My suggestion below is to restore old expected behavior..
> 
> Agreed, the accept_local sysctl should not be misused for this,
> otherwise TPROXY setups wouldn't have source validation anymore.

Absolutely agreed.

Cheers,
Krisztian

