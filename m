From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 15:18:23 -0500 (EST)
Message-ID: <20141216.151823.2276708539799601894.davem@davemloft.net>
References: <54908FAD.5060500@psc.edu>
	<20141216.150354.64901094367530710.davem@davemloft.net>
	<54909278.6090806@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: rapier@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbaLPUSZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:18:25 -0500
In-Reply-To: <54909278.6090806@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: rapier <rapier@psc.edu>
Date: Tue, 16 Dec 2014 15:13:44 -0500

> On 12/16/14, 3:03 PM, David Miller wrote:
> 
>> You shouldn't need to export any symbols.
> 
> As a point of clarification - is it acceptable to export symbols for
> use with in tree modules such as tcp_htcp? We are more than willing to
> do the work required to bring this in line with best practices.

I'm saying for data and TCP statistics collection, you shouldn't need
to add any new symbol exports.

Keep this in the main kernel, nothing external should be needed.

Extending tcp_info or similar is the only reasonable way to implement
this stuff.
