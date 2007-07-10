From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: iproute2 showing wrong number of bytes on 64bit architectures.
Date: Tue, 10 Jul 2007 12:17:12 -0600
Message-ID: <4693CD28.5070402@nortel.com>
References: <20070710085640.128311d1@freepuppy.rosehill.hemminger.net> <20070710.110545.112620737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:37764 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbXGJSbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 14:31:11 -0400
In-Reply-To: <20070710.110545.112620737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> It used unsigned long ages ago, and ifconfig gets the bits
> exported from /proc/net/dev output whereas we have to used
> fixed data types in whatever we use over netlink so u32
> was choosen.

It's rather ironic that the "new-and-improved" way of doing things is 
subject to rollover while the "old" way is not.

Chris
