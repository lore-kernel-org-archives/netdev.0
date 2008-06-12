From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver updates for .27
Date: Thu, 12 Jun 2008 18:08:23 -0400
Message-ID: <48519E57.3030906@garzik.org>
References: <20080612023046.GA25958@havoc.gtf.org>	<20080612133842.0dc472bc.sfr@canb.auug.org.au> <20080611.212929.71729484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58091 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751797AbYFLWI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2008 18:08:29 -0400
In-Reply-To: <20080611.212929.71729484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 12 Jun 2008 13:38:42 +1000
> 
>> Hi Jeff,
>>
>> On Wed, 11 Jun 2008 22:30:46 -0400 Jeff Garzik <jeff@garzik.org> wrote:
>>> Stephen Rothwell (1):
>>>       [netdrvr] Fix 8390 build breakage
>> That patch is actually from Tony Breeds ..
> 
> Jeff, there is still time to fix this.  If you want, just
> fix up that patch in your tree to get the attribution
> and author field correct, and send me a new pull request.

Did you actually read the commit description?  It's quite clear who 
originated the commit:


commit 0c1aa20fb87b796d904f4d89ad12e5a0c483127b
Author: Stephen Rothwell <sfr@canb.auug.org.au>
Date:   Thu May 29 22:39:28 2008 +1000

     [netdrvr] Fix 8390 build breakage

     From: tony@bakeyournoodle.com (Tony Breeds)

     ...

     Signed-off-by: Tony Breeds <tony@bakeyournoodle.com>
     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>


It's pretty hard to miss, and it accurately captures the entire audit trail:

1) who sent the patch?
2) who wrote the patch?
3) who committed the patch?

So, you want to eliminate part of that audit trail (#1), making the 
commit audit trail more hidden and opaque?

I respectfully disagree.  We should capture the _entire_ audit trail, 
not hide bits of it.

Full credit is given, as you can see from looking at the commit.

	Jeff



