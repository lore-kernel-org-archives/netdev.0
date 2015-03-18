From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] tipc: add support for connect() on
 dgram/rdm sockets
Date: Wed, 18 Mar 2015 14:48:16 -0400 (EDT)
Message-ID: <20150318.144816.1470893128899579539.davem@davemloft.net>
References: <1426670263-30358-1-git-send-email-erik.hugne@ericsson.com>
	<1426670263-30358-4-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com, jon.maloy@ericsson.com,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932889AbbCRSsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 14:48:19 -0400
In-Reply-To: <1426670263-30358-4-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Wed, 18 Mar 2015 10:17:43 +0100

> +	} else if (unlikely(m->msg_namelen < sizeof(*dest)) ||
> +		     dest->family != AF_TIPC) {

This is not indented correctly.

The "dest->family" on the second line should start exactly at the first
column after the openning parenthesis of the if() statement on the
previous line.
