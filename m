From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net.git] net: Fix recvmmsg timeout handling
Date: Wed, 23 Jul 2014 14:51:24 -0700 (PDT)
Message-ID: <20140723.145124.1007842943001121868.davem@davemloft.net>
References: <20140721192131.GA3212@kernel.org>
	<20140721.204538.1952841990990568877.davem@davemloft.net>
	<20140722194851.GG20303@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mtk.manpages@gmail.com, caitlin.bestler@gmail.com,
	chris.friesen@windriver.com, David.Laight@ACULAB.COM,
	eliedebrauwer@gmail.com, nhorman@tuxdriver.com, neleai@seznam.cz,
	paul@paul-moore.com, remi@remlab.net, steve@chygwyn.com,
	netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38114 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933543AbaGWVv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 17:51:26 -0400
In-Reply-To: <20140722194851.GG20303@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@kernel.org>
Date: Tue, 22 Jul 2014 16:48:51 -0300

> Em Mon, Jul 21, 2014 at 08:45:38PM -0700, David Miller escreveu:
>> From: Arnaldo Carvalho de Melo <acme@kernel.org>
>> Date: Mon, 21 Jul 2014 16:21:31 -0300
>> 
>> > 	Trying to get this merged, finally. I has whas has been
>> > discussed so far and agreed wrt the timeout handling.
>> 
>> This gets lots of rejects against the current 'net' tree.
>> 
>> Please respin and integrate Remi's Acked-by, thanks.
> 
> Here it is, I think we should wait a bit till Michael (and whoever else
> is up to test this today) can test it, Michael?

I don't see any testing feedback yet.

Also, Arnaldo, if you could submit patches in the standard way
that would help me a lot.  Subject line is fine, but you're then
just inserting the output of something like "git show" into the
email body.

That makes a lot of work for me, therefore it helps a lot if you
submit things in a format that just works if I feed your email into
"git am".

This means the email body is the commit message body, then you
can put the standard separator "---" and then any anchillary messages
or information you want to tell me like "let's wait for so and so
to test this" that you don't want to make it into the git commit
itself.

Then you provide the patch after all that.

This is exactly what you would obtain if you used git send-email
or similar, editing the final result to your liking.

Thanks.
