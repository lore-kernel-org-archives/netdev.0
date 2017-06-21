From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] ldmvsw: add vio version and remote-mac to
 ethtool info
Date: Wed, 21 Jun 2017 17:27:40 -0400 (EDT)
Message-ID: <20170621.172740.195647522322509090.davem@davemloft.net>
References: <1498061394-233018-2-git-send-email-shannon.nelson@oracle.com>
        <20170621.150546.230947714652245325.davem@davemloft.net>
        <732eb629-450f-bfae-4535-0c6e5b2ccbe0@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sparclinux@vger.kernel.org
To: shannon.nelson@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46522 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751130AbdFUV1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 17:27:43 -0400
In-Reply-To: <732eb629-450f-bfae-4535-0c6e5b2ccbe0@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@oracle.com>
Date: Wed, 21 Jun 2017 13:59:35 -0700

> On 6/21/2017 12:05 PM, David Miller wrote:
>> Also, this is not at all an appropriate place to expose this.  The
>> "driver info" ethtool command is not a place to post per-connection
>> or per-link information.
> 
> I knew it was a bit of a stretch, but almost made sense.  However, I'd
> still like to put the vio version here - is that acceptable?

That part is fine.

>> Probably one of the IFLA_* netlink attributes would work best for
>> this.  You could even use PHYS_PORT_ID for this, which gives you
>> 32 bytes to work with.
> 
> Hmmm - good thought.  I'll go poke at this and see what I can come up
> with.  I gather from this that you agree that /sys is not the right
> place for this information, either.

Netlink is definitely preferred.
