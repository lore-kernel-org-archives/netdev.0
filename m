From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] team: bcast: convert return value of
 team_dev_queue_xmit() to bool correctly
Date: Wed, 21 Nov 2012 11:55:47 -0500 (EST)
Message-ID: <20121121.115547.1062092538532584924.davem@davemloft.net>
References: <1353501285-1340-1-git-send-email-jiri@resnulli.us>
	<20121121125328.GA6812@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755335Ab2KUQzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 11:55:50 -0500
In-Reply-To: <20121121125328.GA6812@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 21 Nov 2012 13:53:28 +0100

> 
> I forgot to mention this bug was introduced by:
> team: add broadcast mode (5fc889911a99043a97da1daa0d010ad72cbc3042)
> 
> Wed, Nov 21, 2012 at 01:34:45PM CET, jiri@resnulli.us wrote:
>>The thing is that team_dev_queue_xmit() returns NET_XMIT_* or -E*.
>>bc_trasmit() should return true in case all went well. So use ! to get
>>correct retval from team_dev_queue_xmit() result.
>>This bug caused iface statistics to be badly computed.
>>
>>Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
>>Signed-off-by: Jiri Pirko <jiri@resnulli.us>

I incorporated the reference to the bug introducing commit and
applied this patch, thanks.
