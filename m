From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5 net-next] vxlan: virtual extensible lan
Date: Thu, 27 Sep 2012 19:12:00 -0400 (EDT)
Message-ID: <20120927.191200.1483743406607177228.davem@davemloft.net>
References: <20120925150957.78591205@nehalam.linuxnetplumber.net>
	<20120927.184740.975766966558033959.davem@davemloft.net>
	<20120927160054.105f4711@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, chrisw@redhat.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754595Ab2I0XMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 19:12:02 -0400
In-Reply-To: <20120927160054.105f4711@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 27 Sep 2012 16:00:54 -0700

> On Thu, 27 Sep 2012 18:47:40 -0400 (EDT)
> David Miller <davem@davemloft.net> wrote:
> 
>> But I wonder if this matters at all, the administrator controls
>> the contents of this table, rather than external entitites.
> 
> The table includes values learned from packets received. Like a bridge,
> a malicious attacker who can forge MAC sourc addresses can overload one
> chain by swamping the table with bogus values.  Probably needs a table limit.

Ok.
