From: David Miller <davem@davemloft.net>
Subject: Re: [ANN] Unified dynamic storage for different socket types
 instead of separate hash tables.
Date: Thu, 22 Mar 2007 12:14:41 -0700 (PDT)
Message-ID: <20070322.121441.39171370.davem@davemloft.net>
References: <20070322185944.GA3802@2ka.mipt.ru>
	<20070322.120346.41643926.davem@davemloft.net>
	<20070322190939.GA18792@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35932
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965405AbXCVTOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 15:14:41 -0400
In-Reply-To: <20070322190939.GA18792@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 22 Mar 2007 22:09:40 +0300

> I specially have only one hash structure in the socket - skc_bind_node -
> to be used for statistics and remove hash and skc_node (and for netlink
> broadcasting too), so this code reduces socket structure by 12 bytes on
> x86 (20 bytes on x86_64).

Yes, for your trie you've removed quite a bit, but now you're
going to add 2 pointers right back right?
