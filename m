From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: do not erase dst address with flow label
 destination
Date: Tue, 10 Dec 2013 22:51:20 -0500 (EST)
Message-ID: <20131210.225120.1914484052513584704.davem@davemloft.net>
References: <1386684946-18510-1-git-send-email-florent.fourcot@enst-bretagne.fr>
	<20131210205822.GB25505@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florent.fourcot@enst-bretagne.fr, netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab3LKDvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 22:51:21 -0500
In-Reply-To: <20131210205822.GB25505@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 10 Dec 2013 21:58:22 +0100

> On Tue, Dec 10, 2013 at 03:15:46PM +0100, Florent Fourcot wrote:
>> This patch is following b579035ff766c9412e2b92abf5cab794bff102b6
>> 	"ipv6: remove old conditions on flow label sharing"
>> 
>> Since there is no reason to restrict a label to a
>> destination, we should not erase the destination value of a
>> socket with the value contained in the flow label storage.
>> 
>> This patch allows to really have the same flow label to more
>> than one destination.
>> 
>> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> 
> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
