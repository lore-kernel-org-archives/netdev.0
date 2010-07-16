From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Question about way that NICs deliver packets to the kernel
Date: Fri, 16 Jul 2010 10:58:46 -0700
Message-ID: <4C409DD6.7060903@hp.com>
References: <20100715142418.GA26491@host-a-229.ustcsz.edu.cn>	<1279204417.2118.12.camel@achroite.uk.solarflarecom.com> <AANLkTild5SQvt7Uw7AAV7BrrSdvPdoglgbm1uJQnigdM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:35675 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757297Ab0GPR6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 13:58:49 -0400
In-Reply-To: <AANLkTild5SQvt7Uw7AAV7BrrSdvPdoglgbm1uJQnigdM@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Junchang Wang wrote:
>>You should also compare the CPU usage.
>>
>>Ben.
>>
> 
> Hi Ben,
> I added options -c -C to netperf's command line. Result is as follows:
>                     scheme 1    scheme 2    Imp.
> Throughput:     683M        718M       5%
> CPU usage:     47.8%       45.6%
> 
> That really surprised me because "top" command showed the CPU usage
> was fluctuating between 0.5% and 1.5% rather that between 45% and 50%.

Can you tell us a bit more about the system, and which version of netperf you 
are using?  Any chance that the CPU utilization you were looking at in top was 
just that being charged to netperf the process?  "Network processing" does not 
often get charged to the responsible process, so netperf reports system-wide CPU 
utilization on the assumption it is the only thing causing the CPUs to be utilized.

happy benchmarking,

rick jones
