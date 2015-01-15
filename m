From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] genetlink: synchronize socket closing and family
 removal
Date: Thu, 15 Jan 2015 18:06:48 -0500 (EST)
Message-ID: <20150115.180648.1866614155229401390.davem@davemloft.net>
References: <1421319885-31779-3-git-send-email-johannes@sipsolutions.net>
	<20150115.145007.184934220260873768.davem@davemloft.net>
	<1421355306.1962.14.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff.layton@primarydata.com,
	sedat.dilek@gmail.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbbAOXGw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 18:06:52 -0500
In-Reply-To: <1421355306.1962.14.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 15 Jan 2015 21:55:06 +0100

> On Thu, 2015-01-15 at 14:50 -0500, David Miller wrote:
>> From: Johannes Berg <johannes@sipsolutions.net>
>> Date: Thu, 15 Jan 2015 12:04:45 +0100
>> 
>> > +		atomic_dec(&genl_sk_destructing_cnt);
>> > +		printk(KERN_DEBUG "dec destructing\n");
>> > +		wake_up(&genl_sk_destructing_waitq);
>> 
>> Hmmm, maybe only wakeup if "!atomic_dec_and_test()"?
> 
> Yes, good point.
> 
> And, umm, how the hell did I manage to leave the printk() in there?

Johannes, please repost the whole series when you have to make
changes to one or more of the patches within.

Thanks.
