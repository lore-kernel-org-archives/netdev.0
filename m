From: Masatake YAMATO <yamato@redhat.com>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too
 long
Date: Thu, 21 Mar 2013 16:49:09 +0900 (JST)
Message-ID: <20130321.164909.2042907187785078622.yamato@redhat.com>
References: <1363693648-10015-2-git-send-email-yamato@redhat.com>
	<20130320.120705.58997943737455552.davem@davemloft.net>
	<1363800779.2677.16.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20156 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932998Ab3CUHtS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 03:49:18 -0400
In-Reply-To: <1363800779.2677.16.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I will look at sparse whether it can capture this kind of mistake.

Masatake YAMATO

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 20 Mar 2013 17:32:59 +0000
> On Wed, 2013-03-20 at 12:07 -0400, David Miller wrote:
>> From: Masatake YAMATO <yamato@redhat.com>
>> Date: Tue, 19 Mar 2013 20:47:27 +0900
>> 
>> > Trigger BUG_ON if a group name is longer than GENL_NAMSIZ.
>> > 
>> > Signed-off-by: Masatake YAMATO <yamato@redhat.com>
>> 
>> Applied, thanks.
>> 
>> Although I'm disappointed that the compiler doesn't say anything about
>> this in the assignment.
>> 
>> We're assigning "char[16] = STRING" and it doesn't say anything if the
>> final NULL char doesn't fit into the array.
> 
> Unfortunately the C standard says this is allowed.  (Though the C++
> standard says it's not!)  That doesn't mean the compiler can't warn
> about it, of course.
> 
> Ben.
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
> 
