From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Fix the fib trie iterator to work with a single entry routing tables
Date: Wed, 24 Jan 2007 19:11:51 -0700
Message-ID: <m1tzyfzwgo.fsf@ebiederm.dsl.xmission.com>
References: <m17ivc19na.fsf@ebiederm.dsl.xmission.com>
	<17847.54018.72176.431127@robur.slu.se>
	<20070124.144254.78492493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Robert.Olsson@data.slu.se, netdev@vger.kernel.org,
	robert.olsson@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34162 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbXAYCMh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 21:12:37 -0500
In-Reply-To: <20070124.144254.78492493.davem@davemloft.net> (David Miller's
	message of "Wed, 24 Jan 2007 14:42:54 -0800 (PST)")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> From: Robert Olsson <Robert.Olsson@data.slu.se>
> Date: Wed, 24 Jan 2007 22:43:30 +0100
>
>> Yes the case when the trie is just a single leaf got wrong with the
>> iterator and your patchs cures it. I think we have a similar problem
>> with /proc/net/fib_trie
>
> I'm happy to review a fix for that :-)
>
>> Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>
>
> Patch applied, thanks everyone.

Same iterator function so this fixes that as well.

Eric

