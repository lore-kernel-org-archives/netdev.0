From: David Miller <davem@davemloft.net>
Subject: Re: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
Date: Thu, 31 Jul 2014 12:21:20 -0700 (PDT)
Message-ID: <20140731.122120.1264255119985284020.davem@davemloft.net>
References: <1836813.giEndUKvmp@storm>
	<20140730002255.GA16109@kroah.com>
	<20140730063703.GA24753@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, thomas.jarosch@intra2net.com,
	netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206AbaGaTVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 15:21:21 -0400
In-Reply-To: <20140730063703.GA24753@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 30 Jul 2014 08:37:03 +0200

> However, given the numerous problems reported with the GRO changes in
> older stable kernels I think the commit
> 29a3cd46644ec8098dbe1c12f89643b5c11831a9 in 3.4.y should be reverted.
> 
> [ In 3.2.y its caa5344994778a2b4725b2d75c74430f76925e4a ]
 ...
> David, in case I remember wrong and you did not recommend the revert
> after all, do you want me to submit 3.2/3.4.y backport of Erics
> 'set transport header earlier' patch?

Yes, the above two patches above should be reverted.

Thanks Florian.
