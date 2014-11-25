From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre: Set inner mac header in gro complete
Date: Tue, 25 Nov 2014 14:35:30 -0500 (EST)
Message-ID: <20141125.143530.1055990826405505003.davem@davemloft.net>
References: <1416936611-22702-1-git-send-email-therbert@google.com>
	<1416938241.29427.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, linux@stwm.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37548 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbaKYTfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:35:32 -0500
In-Reply-To: <1416938241.29427.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Nov 2014 09:57:21 -0800

> On Tue, 2014-11-25 at 09:30 -0800, Tom Herbert wrote:
>> Set the inner mac header to point to the GRE payload when
>> doing GRO. This is needed if we proceed to send the packet
>> through GRE GSO which now uses the inner mac header instead
>> of inner network header to determine the length of encapsulation
>> headers.
>> 
>> Reported-by: Wolfgang Walter <linux@stwm.de>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
> 
> Please Tom, add in your bug fixes something to ease backports.
> 
> Fixes: 14051f0452a2 ("gre: Use inner mac length when computing tunnel length")

Also this is extremely far reaching consequences.

The bug is in Linus's tree, so net-next is not a suitable target,
'net' is.

Also, the commit in question has been backported into -stable, so
I would need to queue it up there as well.

Please respin this against 'net', and add the Fixes: tag, thanks.
