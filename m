From: David Miller <davem@davemloft.net>
Subject: Re: GPF in ip6_dst_lookup_tail
Date: Fri, 07 Dec 2012 13:05:26 -0500 (EST)
Message-ID: <20121207.130526.1080050980773998334.davem@davemloft.net>
References: <20121207141525.GA20613@redhat.com>
	<20121207.124315.106563528177056022.davem@davemloft.net>
	<20121207180428.GA3884@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423611Ab2LGSF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 13:05:28 -0500
In-Reply-To: <20121207180428.GA3884@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Fri, 7 Dec 2012 13:04:28 -0500

> On Fri, Dec 07, 2012 at 12:43:15PM -0500, David Miller wrote:
>  > From: Dave Jones <davej@redhat.com>
>  > Date: Fri, 7 Dec 2012 09:15:25 -0500
>  > 
>  > > I just hit this gpf in overnight testing.
>  > 
>  > Hmmm, perhaps introduced by:
>  > 
>  > commit f950c0ecc78f745e490d615280e031de4dbb1306
>  > Author: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>  > Date:   Thu Sep 20 18:29:56 2012 +0000
>  > 
>  >     ipv6: fix return value check in fib6_add()
>  > 
>  > and fixed by:
>  > 
>  > commit 188c517a050ec5b123e72cab76ea213721e5bd9d
>  > Author: Lin Ming <mlin@ss.pku.edu.cn>
>  > Date:   Tue Sep 25 15:17:07 2012 +0000
>  > 
>  >     ipv6: return errno pointers consistently for fib6_add_1()
>  >     
> 
> That was in the build that I was running.
> (It was Linus' tree from last night, sorry I neglected to mention that)

Ok, it's something else then.
