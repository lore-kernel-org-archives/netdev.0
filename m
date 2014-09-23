From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 04/14] tipc: add sock dump to new netlink api
Date: Tue, 23 Sep 2014 11:37:38 -0400 (EDT)
Message-ID: <20140923.113738.2189831519873566622.davem@davemloft.net>
References: <54169B6C.5060709@ericsson.com>
	<20140915.113846.1276168899072885.davem@davemloft.net>
	<542155AF.4020805@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753971AbaIWPhk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 11:37:40 -0400
In-Reply-To: <542155AF.4020805@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Tue, 23 Sep 2014 13:12:47 +0200

> Ideally I would like to use the existing dump framework .dumpit
> (netlink_dump_start()) but I can't figure out a way to pass the socket
> for which to dump publications. I really don't want to reinvent the
> dumping mechanism. Any suggestions?

Look at inet_diag, and how the dump netlink request passes in a key
to match upon.

The key is of the form: include/uapi/linux/inet_diag.h:inet_diag_req{,_v2}
