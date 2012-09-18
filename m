From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: fix rx checksum validation for IPv6
Date: Tue, 18 Sep 2012 16:17:55 -0400 (EDT)
Message-ID: <20120918.161755.379639106500504747.davem@davemloft.net>
References: <1347577184-8417-1-git-send-email-mschmidt@redhat.com>
	<1347578079.8555.141.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org, eilong@broadcom.com,
	edumazet@google.com, yanivr@broadcom.com, yuvalmin@broadcom.com,
	meravs@broadcom.com, evansr@google.com, therbert@google.com,
	willemb@google.com, hskinnemoen@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754739Ab2IRUR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 16:17:57 -0400
In-Reply-To: <1347578079.8555.141.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 14 Sep 2012 01:14:39 +0200

> On Fri, 2012-09-14 at 00:59 +0200, Michal Schmidt wrote:
>> Commit d6cb3e41 "bnx2x: fix checksum validation" caused a performance
>> regression for IPv6. Rx checksum offload does not work. IPv6 packets
>> are passed to the stack with CHECKSUM_NONE.
>> 
>> The hardware obviously cannot perform IP checksum validation for IPv6,
>> because there is no checksum in the IPv6 header. This should not prevent
>> us from setting CHECKSUM_UNNECESSARY.
>> 
>> Tested on BCM57711.
>> 
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
 ...
> Thanks for fixing this bug !
> 
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> 

Applied, thanks.
