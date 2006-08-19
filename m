From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH 2/9] deadlock prevention core
Date: Sat, 19 Aug 2006 11:06:10 -0400
Message-ID: <44E728E2.4000804@redhat.com>
References: <20060808211731.GR14627@postel.suug.ch>	<44DBED4C.6040604@redhat.com>	<44DFA225.1020508@google.com>	<20060813.165540.56347790.davem@davemloft.net>	<44DFD262.5060106@google.com>	<20060813185309.928472f9.akpm@osdl.org>	<1155530453.5696.98.camel@twins>	<20060813215853.0ed0e973.akpm@osdl.org>	<44E3E964.8010602@google.com>	<20060816225726.3622cab1.akpm@osdl.org>	<44E5015D.80606@google.com>	<20060817230556.7d16498e.akpm@osdl.org>	<44E62F7F.7010901@google.com>	<20060818153455.2a3f2bcb.akpm@osdl.org>	<44E650C1.80608@google.com> <20060818194435.25bacee0.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Phillips <phillips@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Mike Christie <michaelc@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52436 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751469AbWHSPIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Aug 2006 11:08:30 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060818194435.25bacee0.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:

> - We expect that the lots-of-dirty-anon-memory-over-swap-over-network
>   scenario might still cause deadlocks.  
> 
>   I assert that this can be solved by putting swap on local disks.  Peter
>   asserts that this isn't acceptable due to disk unreliability.  I point
>   out that local disk reliability can be increased via MD, all goes quiet.
> 
>   A good exposition which helps us to understand whether and why a
>   significant proportion of the target user base still wishes to do
>   swap-over-network would be useful.

You cannot put disks in many models of blade servers.

At all.

-- 
What is important?  What you want to be true, or what is true?
