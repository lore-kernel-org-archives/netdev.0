From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] qdisc: meta return ENOMEM on alloc failure
Date: Sat, 28 Sep 2013 00:31:25 +0100
Message-ID: <20130927233125.GA12624@casper.infradead.org>
References: <20130926174011.22632779@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35647 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359Ab3I0Xb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 19:31:27 -0400
Content-Disposition: inline
In-Reply-To: <20130926174011.22632779@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/26/13 at 05:40pm, Stephen Hemminger wrote:
> Rather than returning earlier value (EINVAL), return ENOMEM if
> kzalloc fails. Found while reviewing to find another EINVAL condition.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Acked-by: Thomas Graf <tgraf@suug.ch>
