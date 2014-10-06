From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] icmp6: Add new icmpv6 type for RPL control
 message
Date: Mon, 06 Oct 2014 18:13:22 -0400 (EDT)
Message-ID: <20141006.181322.2253854250567400185.davem@davemloft.net>
References: <1412591826-32037-1-git-send-email-simon.vincent@xsilon.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: simon.vincent@xsilon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbaJFWNY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:13:24 -0400
In-Reply-To: <1412591826-32037-1-git-send-email-simon.vincent@xsilon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Vincent <simon.vincent@xsilon.com>
Date: Mon,  6 Oct 2014 11:37:06 +0100

> IANA has defined a type value of 155 for RPL control messages.
> We do nothing if we recieve one of these messages. This patch is to
> avoid getting lots of icmpv6 unknown type messages when using RPL.
> 
> Signed-off-by: Simon Vincent <simon.vincent@xsilon.com>

If we agree that pretty much our policy is that we treat as "known"
any ICMPv6 type assigned officially by IANA, then we should simply
add everything missing from the table at:

	http://www.iana.org/assignments/icmpv6-parameters/icmpv6-parameters.xhtml

Any objections?
