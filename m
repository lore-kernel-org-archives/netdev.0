From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add support for receive hashing
Date: Tue, 27 Apr 2010 09:51:08 -0700 (PDT)
Message-ID: <20100427.095108.68126984.davem@davemloft.net>
References: <q2o65634d661004261038t8f0c32f5ye8169ef0c38172b7@mail.gmail.com>
	<20100426.110432.104061817.davem@davemloft.net>
	<4BD6E887.3000804@athenacr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: bmb@athenacr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49774
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750991Ab0D0QvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 12:51:03 -0400
In-Reply-To: <4BD6E887.3000804@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Bloniarz <bmb@athenacr.com>
Date: Tue, 27 Apr 2010 09:37:11 -0400

> David Miller wrote:
>> How damn hard is it to add two 16-bit ports to the hash regardless of
>> protocol?
>>   
> Come to think of it, for UDP the hash must ignore
> the srcport and srcaddr, because a single bound
> socket is going to wildcard both those fields.

For load distribution we don't care if the local socket is wildcard
bounded on source.

It's going to be fully specified in the packet, and that's enough.

Sure, for full RFS some amends might be necessary in this area, but
for RPS and adapter based hw steering, using all of the ports is
entirely sufficient.
