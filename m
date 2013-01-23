From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] IP_GRE: Fix kernel panic in IP_GRE with GRE csum.
Date: Wed, 23 Jan 2013 00:20:42 -0500 (EST)
Message-ID: <20130123.002042.1407506590919624013.davem@davemloft.net>
References: <1358895398-2088-1-git-send-email-pshelar@nicira.com>
	<20130122.205507.339713494072219737.davem@davemloft.net>
	<877gn4iizy.fsf@blp.benpfaff.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, jesse@nicira.com
To: blp@cs.stanford.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768Ab3AWFUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:20:43 -0500
In-Reply-To: <877gn4iizy.fsf@blp.benpfaff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Pfaff <blp@cs.stanford.edu>
Date: Tue, 22 Jan 2013 21:08:33 -0800

> David Miller <davem@davemloft.net> writes:
> 
>> From: Pravin B Shelar <pshelar@nicira.com>
>> Date: Tue, 22 Jan 2013 14:56:38 -0800
>>
>>> Fixed code indentation according to comments from David Miller.
>>> 
>>> --8<--------------------------cut here-------------------------->8--
>>
>> This doesn't do what you think it does.  No automated tool is going
>> to edit the commit message the way you think this will.
> 
> "git am" does if you run with --scissors, see git-am(1):
> 
>        -c, --scissors
>            Remove everything in body before a scissors line (see git-
>            mailinfo(1)).

I'd rather not have to do that for submissions, thanks.
Furthermore patchwork doesn't parse this convention either.
