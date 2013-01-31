From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] l2tp: fix ancillary data handling in ipv6 recv
Date: Wed, 30 Jan 2013 20:32:21 -0500 (EST)
Message-ID: <20130130.203221.113672899098479942.davem@davemloft.net>
References: <1359555686-21588-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, celston@katalix.com
To: tparkin@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab3AaBcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 20:32:23 -0500
In-Reply-To: <1359555686-21588-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Parkin <tparkin@katalix.com>
Date: Wed, 30 Jan 2013 14:21:23 +0000

> Patch 0001 includes some minor whitespace change in order to comply with
> checkpatch.pl's style recommendations.

Those whitspace recommendations do not match what we use in the
networking.

A function call shall be indented like so:

	ret = func(arg1, arg2, arg3,
		   arg4, arg5, arg6);

That is, the arguments on the second and subsequent lines shall
be indented to the first column after the openning parenthesis
of the first line.

You must use whatever combination of TAB and space characters are
necessary to achieve it.

If you are indenting only using TAB characters, it is guarenteed
that you are doing it wrong.

You also need to reindent the arguments in function declarations in
the header files that you modified.  The function name is longer on
the first line, therefore the openning parenthesis appears deeper in
the line, and therefore the second and further lines of the
declaration have to be indent adjusted.

Thanks.
