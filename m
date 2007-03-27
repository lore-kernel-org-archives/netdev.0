From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [ANN] Unified dynamic storage for different socket types instead of separate hash tables.
Date: 27 Mar 2007 16:23:49 +0200
Message-ID: <p73bqie69ze.fsf@bingen.suse.de>
References: <20070322185944.GA3802@2ka.mipt.ru>
	<20070322.120346.41643926.davem@davemloft.net>
	<20070322191449.GA25274@2ka.mipt.ru>
	<20070322.122120.115923509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:48373 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753847AbXC0NZA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 09:25:00 -0400
In-Reply-To: <20070322.122120.115923509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> 
> 2) An extra list insert/delete to give list of all sockets

That is currently limited by readlock on the hash buckets. I suspect
any change to a trie with less atomic operations will make it faster.

-Andi
