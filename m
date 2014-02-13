From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: remove unnecessary return's
Date: Thu, 13 Feb 2014 18:14:16 -0500 (EST)
Message-ID: <20140213.181416.1185115361356253646.davem@davemloft.net>
References: <alpine.DEB.2.02.1402132252290.1967@localhost6.localdomain6>
	<20140213220021.GA1174@redhat.com>
	<alpine.DEB.2.02.1402132327480.1967@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, joe@perches.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbaBMXOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 18:14:19 -0500
In-Reply-To: <alpine.DEB.2.02.1402132327480.1967@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Thu, 13 Feb 2014 23:28:27 +0100 (CET)

> On Thu, 13 Feb 2014, Dave Jones wrote:
> 
>> On Thu, Feb 13, 2014 at 10:55:23PM +0100, Julia Lawall wrote:
>> 
>>  > The patch below converts label: return; } to label: ; }.  I have only 
>>  > scanned through the patches, not patched the code and looked at the 
>>  > results, so I am not sure that it is completely correct.  On the other 
>>  > hand, I'm also not sure that label: ; } is better than label: return; }, 
>>  > either.  If people think it is, then I can cheack the results in more 
>>  > detail.
>> 
>> Why not delete the label, and just replace the goto with a return if
>> the label is at the end of the function ?
> 
> Here is an example.  Perhaps the uniformity of the if ... goto pattern is 
> valuable, though?

I think it is valuable, it's so much easier to audit the return paths
via a process of elimination with that kind of layout.  A return in
the middle of that looks out of place at best.
