From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: rps perfomance WAS(Re: rps: question
Date: Wed, 14 Apr 2010 11:53:52 -0700
Message-ID: <20100414115352.598521af@nehalam>
References: <1265568122.3688.36.camel@bigi>
	<65634d661002072158r48ec15cag1ca58e704114a358@mail.gmail.com>
	<1265641748.3688.56.camel@bigi>
	<1271245986.3943.55.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	robert@herjulf.net, David Miller <davem@davemloft.net>,
	Changli Gao <xiaosuo@gmail.com>,
	Andi Kleen <andi@firstfloor.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33489 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756401Ab0DNSyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Apr 2010 14:54:11 -0400
In-Reply-To: <1271245986.3943.55.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Apr 2010 07:53:06 -0400
jamal <hadi@cyberus.ca> wrote:

> Results:
> CPU utilization was about 20-30% higher in the case of rps. On cpu0, the
> cpu was being chewed highly by sky2_poll and on the redirected-to-core
> it was always smp_call_function_single

I posted a patch to use sky2 hardware hash (RSS) which should lower the
cost per packet.

-- 
