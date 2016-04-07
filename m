From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mark DECnet as broken
Date: Thu, 07 Apr 2016 12:21:24 -0400 (EDT)
Message-ID: <20160407.122124.1542811219982329414.davem@davemloft.net>
References: <1460013763-22985-1-git-send-email-vegard.nossum@oracle.com>
	<20160407150120.22934228@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@oracle.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	sasha.levin@oracle.com
To: gnomes@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011AbcDGQV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 12:21:26 -0400
In-Reply-To: <20160407150120.22934228@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Date: Thu, 7 Apr 2016 15:01:20 +0100

> On Thu,  7 Apr 2016 09:22:43 +0200
> Vegard Nossum <vegard.nossum@oracle.com> wrote:
> 
>> There are NULL pointer dereference bugs in DECnet which can be triggered
>> by unprivileged users and have been reported multiple times to LKML,
>> however nobody seems confident enough in the proposed fixes to merge them
>> and the consensus seems to be that nobody cares enough about DECnet to
>> see it fixed anyway.
>> 
>> To shield unsuspecting users from the possible DOS, we should mark this
>> BROKEN until somebody who actually uses this code can fix it.
> 
> How about consigning it to staging at this point ?

Staging is a one way facility in my opinion.

I saw we just fix the NULL dereference.
