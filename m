From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Thu, 17 Aug 2006 16:53:01 -0700
Message-ID: <44E5015D.80606@google.com>
References: <20060808211731.GR14627@postel.suug.ch>	<44DBED4C.6040604@redhat.com>	<44DFA225.1020508@google.com>	<20060813.165540.56347790.davem@davemloft.net>	<44DFD262.5060106@google.com>	<20060813185309.928472f9.akpm@osdl.org>	<1155530453.5696.98.camel@twins>	<20060813215853.0ed0e973.akpm@osdl.org>	<44E3E964.8010602@google.com> <20060816225726.3622cab1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>, riel@redhat.com,
	tgraf@suug.ch, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:36980 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1751233AbWHQX4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Aug 2006 19:56:49 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060816225726.3622cab1.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Daniel Phillips <phillips@google.com> wrote:
>>What happened to the case where we just fill memory full of dirty file
>>pages backed by a remote disk?
> 
> Processes which are dirtying those pages throttle at
> /proc/sys/vm/dirty_ratio% of memory dirty.  So it is not possible to "fill"
> memory with dirty pages.  If the amount of physical memory which is dirty
> exceeds 40%: bug.

Hi Andrew,

So we make 400 MB of a 1 GB system unavailable for write caching just to
get around the network receive starvation issue?

What happens if some in kernel user grabs 68% of kernel memory to do some
very important thing, does this starvation avoidance scheme still work?

Regards,

Daniel
