From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 04/14] tipc: add sock dump to new netlink api
Date: Mon, 15 Sep 2014 11:38:46 -0400 (EDT)
Message-ID: <20140915.113846.1276168899072885.davem@davemloft.net>
References: <1410424167-17427-5-git-send-email-richard.alpe@ericsson.com>
	<20140912.171038.1165432718811920305.davem@davemloft.net>
	<54169B6C.5060709@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752740AbaIOPit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 11:38:49 -0400
In-Reply-To: <54169B6C.5060709@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Mon, 15 Sep 2014 09:55:24 +0200

> The amount of publications a socket can have is large (~65 000). Do
> you still think this a viable solution?

Then maybe you want to have a completely separate netlink operation to
dump the publications, the request would provide a key saying which
socket's publications to dump.
