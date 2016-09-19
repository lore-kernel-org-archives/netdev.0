From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] sctp: make use of WORD_TRUNC macro
Date: Sun, 18 Sep 2016 22:06:29 -0400 (EDT)
Message-ID: <20160918.220629.1190601768509139321.davem@davemloft.net>
References: <b40b1bd4adff2d389588d9a4710af0399ce68d1e.1473963064.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51658 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936368AbcISCGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 22:06:32 -0400
In-Reply-To: <b40b1bd4adff2d389588d9a4710af0399ce68d1e.1473963064.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Thu, 15 Sep 2016 15:12:30 -0300

> No functional change. Just to avoid the usage of '&~3'.
> Also break the line to make it easier to read.

You're reply later in this thread:

	"to make sure it is correctly adapted to some arch if
	necessary. (even though it's not necessary in this case)"

is inconsistent with your commit log message.

If you think that the word size might possibly be different
on a given arch, then this is in fact a functional change.

This patch just adds ambiguity.  Whereas the existing code is explicit
about "multiple of 4" and there can be no confusion.

I'm not applying this, sorry.
