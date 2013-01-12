From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] networking/cs89x0.txt: delete stale
 information about hand patching
Date: Fri, 11 Jan 2013 16:52:00 -0800 (PST)
Message-ID: <20130111.165200.1745883038834908852.davem@davemloft.net>
References: <20130112004558.GB4625@windriver.com>
	<20130111.164717.998537291622337013.davem@davemloft.net>
	<20130112005109.GC4625@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753355Ab3ALAwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2013 19:52:01 -0500
In-Reply-To: <20130112005109.GC4625@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 11 Jan 2013 19:51:09 -0500

> [Re: [PATCH net-next] networking/cs89x0.txt: delete stale information about hand patching] On 11/01/2013 (Fri 16:47) David Miller wrote:
> 
>> From: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Date: Fri, 11 Jan 2013 19:45:58 -0500
>> 
>> > [Re: [PATCH net-next] networking/cs89x0.txt: delete stale information about hand patching] On 11/01/2013 (Fri 16:31) David Miller wrote:
>> > 
>> >> From: Paul Gortmaker <paul.gortmaker@windriver.com>
>> >> Date: Fri, 11 Jan 2013 19:19:36 -0500
>> >> 
>> >> > Output of a git grep happened to make me look into this file, and
>> >> > I found instructions about how to hand patch (without using patch)
>> >> > the driver into the kernel tree.
>> >> > 
>> >> > Since the driver has been a part of the mainline kernel for years,
>> >> > we can dump this whole section.  Fortunately it doesn't even cause
>> >> > a renumbering of the sections to do so.
>> >> > 
>> >> > Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>> >> 
>> >> When removing a section you should fix up the numbers of the
>> >> remaining sections and any cross references within.
>> > 
>> > Ah crap, I was so glad that I didn't have to renumber anything, that
>> > I did forget to delete the dangling TOC entry; thanks for spotting
>> > that, and sorry for the v2 on something so trivial.
>> 
>> Section 5 is still numbered 5, you didn't renumber the sections after
>> the one you are removing, as I asked you to.
> 
> I deleted section 4.4 -- which was the last section in 4.x -- there
> still is sections 4.0 --> 4.3 so there is no renumbering required.

My bad, I thought 4.x was empty, I'll apply this, thanks.
