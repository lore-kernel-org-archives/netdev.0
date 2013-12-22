From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: act: Dont increment refcnt on
 replace
Date: Sun, 22 Dec 2013 17:50:15 -0500 (EST)
Message-ID: <20131222.175015.561115381077901987.davem@davemloft.net>
References: <52B6DC9B.9060309@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	eric.dumazet@gmail.com
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438Ab3LVWuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 17:50:19 -0500
In-Reply-To: <52B6DC9B.9060309@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sun, 22 Dec 2013 07:35:39 -0500

> This bug seems to have been around for some time, nothing to do with
> recent changes; i am just doing tests i havent run in a while and
> saw it. It is against net-next. If you think it is important enough,
> I could also create one against linus tree..

Jamal, I've tried to be patient with you over the years, but I really
need you to start submitting your changes more cleanly.

Your SUBJECT line MUST be the first line of the commit log message,
optionally with a prefix of the form "[PATCH xxx]" where "xxx" can
be "net", "net-next" and also contain versioning information such
as "v2" or "v3" etc.

Then your email message body must contain the commit message, with
no indentation whatsoever.

Then you may optionally provide a line with "---" then supplementary
information and text which you don't wish to end up in the final
commit message.

Then you provide the patch.

And this all must be inline and not as an attachment.

What I get from you is the output of "git show" as an attachment and I
absolutely cannot use that as-is.  It idents the commit message,
amongst other things.

You can use "git format-patch" instead and munge it into a proper
email by hand.  Unlike "git show", "git format-patch" won't indent
the commit message.

Please take a few moments to read other netdev patch postings
and see how regulars do it.  They do what works for me.

Thank you.
