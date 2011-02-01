From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove fib_hash.
Date: Tue, 01 Feb 2011 15:35:04 -0800 (PST)
Message-ID: <20110201.153504.260089860.davem@davemloft.net>
References: <20110201.151941.48509941.davem@davemloft.net>
	<20110201152603.3ce5bd26@nehalam>
	<20110201153332.46a38ad8@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52908
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751414Ab1BAXe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 18:34:29 -0500
In-Reply-To: <20110201153332.46a38ad8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 1 Feb 2011 15:33:32 -0800

> On Tue, 1 Feb 2011 15:26:03 -0800
> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
>> On Tue, 01 Feb 2011 15:19:41 -0800 (PST)
>> David Miller <davem@davemloft.net> wrote:
>> 
>> > 
>> > The time has finally come to remove the hash based routing table
>> > implementation in ipv4.
>> > 
>> > FIB Trie is mature, well tested, and I've done an audit of it's code
>> > to confirm that it implements insert, delete, and lookup with the same
>> > identical semantics as fib_hash did.
>> > 
>> > If there are any semantic differences found in fib_trie, we should
>> > simply fix them.
>> > 
>> > I've placed the trie statistic config option under advanced router
>> > configuration.
>> > 
>> > Signed-off-by: David S. Miller <davem@davemloft.net>
>> 
>> Vyatta has been shipping FIB TRIE for over 3 years with reported
>> bugs.
> 
> NO reported bugs!!

Understood. :-)

Thanks for reviewing Stephen.
