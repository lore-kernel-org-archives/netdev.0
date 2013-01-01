From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] Add complementary BPF conditional jump
 instructions
Date: Mon, 31 Dec 2012 21:18:00 -0800 (PST)
Message-ID: <20121231.211800.1021263690220417469.davem@davemloft.net>
References: <cover.1356960070.git.dborkman@redhat.com>
	<20121231.143715.1238174487756359071.davem@davemloft.net>
	<1357010942.21409.8948.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56820 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab3AAFSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2013 00:18:05 -0500
In-Reply-To: <1357010942.21409.8948.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 31 Dec 2012 19:29:02 -0800

> On Mon, 2012-12-31 at 14:37 -0800, David Miller wrote:
> 
>> Whilst I agree that adding NE jumps adds great value and closes a
>> serious gap, the rest can be synthesized by simply swapping the
>> arguments and using a comparison that does already exist.
>> 
>> Why isn't that sufficient?
> 
> I am afraid none of these patches is needed at all.
> 
> Swapping the jt/jf is plainly enough for the user land compiler.
> 
> libcap seems to do it already

Agreed.
