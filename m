From: David Miller <davem@davemloft.net>
Subject: Re: forwarding of ipv4 link local addresses
Date: Thu, 03 Dec 2015 14:35:31 -0500 (EST)
Message-ID: <20151203.143531.282555789343463670.davem@davemloft.net>
References: <565E12BE.90006@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbbLCTfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 14:35:33 -0500
In-Reply-To: <565E12BE.90006@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 1 Dec 2015 13:35:58 -0800

> RFC 3927 states that packets from/to IPv4 link-local addresses
> (169.254/16) should not be forwarded, yet the Linux networking stack
> happily forwards them. Before sending in a patch I wanted to inquire
> if this behavior is intentional.

It probably won't break anything if we prohibit this, so sure send
a patch.
