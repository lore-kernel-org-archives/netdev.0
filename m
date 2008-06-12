From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver updates for .27
Date: Thu, 12 Jun 2008 18:43:33 -0400
Message-ID: <4851A695.7050706@garzik.org>
References: <20080612133842.0dc472bc.sfr@canb.auug.org.au>	<20080611.212929.71729484.davem@davemloft.net>	<48519E57.3030906@garzik.org> <20080612.152214.21877307.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60365 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023AbYFLWnl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2008 18:43:41 -0400
In-Reply-To: <20080612.152214.21877307.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Thu, 12 Jun 2008 18:08:23 -0400
> 
>> Did you actually read the commit description?  It's quite clear who 
>> originated the commit:
>>
>>
>> commit 0c1aa20fb87b796d904f4d89ad12e5a0c483127b
>> Author: Stephen Rothwell <sfr@canb.auug.org.au>
>> Date:   Thu May 29 22:39:28 2008 +1000
>>
>>      [netdrvr] Fix 8390 build breakage
>>
>>      From: tony@bakeyournoodle.com (Tony Breeds)
> 
> To each their own, I suppose, but...
> 
> If you look at what happens when Andrew dumps a thousand patches to
> Linus this isn't how it is handled.

Sure, Andrew has an alternate method of including himself the audit 
trail:  adding a signed-off-by line.

sfr didn't do that, and I certainly am not going to add one on his 
behalf (and given email mess, the turnaround would have taken a long 
time if I had asked via email).


> "Author" is always who wrote the patch, and I think it's important to
> be consistent in that area.

"always"?  There are /plenty/ of occasions, usually at big corps, where 
the Author is not the person who wrote the patch, but rather the person 
who sent the patch.

And you'll note that all Linus's tools capture that -- author is patch 
sender -- albeit with optional From parsing from patch commit description.


> Stephen Rothwell isn't the "Author" of this patch any more than you
> are Jeff.  By your own logic, you are saying that you could have just
> as equally put yourself in the Author field since hey, you're
> effectively submitting the patch to me via your tree right? :-)

My own logic is merely that we should capture the entire audit trail.

You are welcome to pull netdev-2.6.git#davem-silly if you don't think 
the existing pull is sufficient, though.

	Jeff


