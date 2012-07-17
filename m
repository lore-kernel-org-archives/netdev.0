From: David Miller <davem@davemloft.net>
Subject: Re: limit allocation size in ieee802154_sock_sendmsg
Date: Mon, 16 Jul 2012 22:48:37 -0700 (PDT)
Message-ID: <20120716.224837.2239403626042263945.davem@davemloft.net>
References: <20120711221209.GA30506@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46259 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027Ab2GQFsn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 01:48:43 -0400
In-Reply-To: <20120711221209.GA30506@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Wed, 11 Jul 2012 18:12:09 -0400

> Sasha reported this last November (https://lkml.org/lkml/2011/11/22/41)
> and I keep walking into it while fuzz testing.

net/ieee802154/dgram.c:dgram_sendmsg() now limits the size to the
device MTU, so you should not hit this problem any more.
