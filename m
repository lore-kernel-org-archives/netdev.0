From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4 : igmp : optimize timer modify logic in
 igmp_mod_timer()
Date: Wed, 23 Nov 2011 19:04:28 -0500 (EST)
Message-ID: <20111123.190428.1925341377347198202.davem@davemloft.net>
References: <1322066322-4782-1-git-send-email-mypopydev@gmail.com>
	<20111123.172814.1626722266908002386.davem@davemloft.net>
	<1322088885.5402.17.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: mypopydev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243Ab1KXAEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 19:04:30 -0500
In-Reply-To: <1322088885.5402.17.camel@barry.pixelworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jun Zhao <mypopydev@gmail.com>
Date: Thu, 24 Nov 2011 06:54:45 +0800

> On Wed, 2011-11-23 at 17:28 -0500, David Miller wrote:
>> From: Jun Zhao <mypopydev@gmail.com>
>> Date: Thu, 24 Nov 2011 00:38:42 +0800
>> 
>> > When timer is pending and expires less-than-or-equal-to new delay,
>> > we need not used del_timer()/add_timer().
>> > 
>> > Signed-off-by: Jun Zhao <mypopydev@gmail.com>
>> 
>> You did not answer Eric's question, why are you optimizing this
>> less-used code path?
> 
> 1). Oh, in the RFC 3376 $5.2, Page 23:

Then your commit message is terrible.

Your commit message, one the one hand, talks about optimizing the code.

Your explanation here talks about RFC conformance.

Your inconsistencies, and how you ignore important questions posed to
you like Eric's (until I point it out to you) makes your work
incredibly irritating to review and process.

Your patch submissions need to be more well formed and your commit
messages need to explain exactly what your goals are with your change
and how those goals are being met by the patch you are proposing.

When we read "optimize timer modify logic" how the heck are we
supposed to know what this change is actually doing?  Why should we
think that we actually need your change?  How am we supposed to figure
out that you are fixing an RFC conformance issue?

I'm sorry, this patch submission is junk.  Don't send us junk.
