From: Thomas Graf <tgraf@suug.ch>
Subject: Re: libnl - netlink library: Memory leak in address cache?
Date: Thu, 13 Dec 2007 12:27:17 +0100
Message-ID: <20071213112717.GL11220@postel.suug.ch>
References: <62918.538.qm@web51405.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joerg Pommnitz <pommnitz@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56562 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752253AbXLML04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 06:26:56 -0500
Content-Disposition: inline
In-Reply-To: <62918.538.qm@web51405.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Joerg Pommnitz <pommnitz@yahoo.com> 2007-12-11 06:52
> I think the leak comes from addr_msg_parser. The newly created address object gets added to the cache with nl_cache_add wich takes a reference, so the reference in addr_msg_parser should be dropped, e.g. the following patch might be correct:

That's correct, thanks for catching this.
