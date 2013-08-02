From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: rtm_to_ifaddr: free ifa if ifa_cacheinfo
 processing fails
Date: Fri, 02 Aug 2013 14:56:42 -0700 (PDT)
Message-ID: <20130802.145642.1722240129413896432.davem@davemloft.net>
References: <1375435963-30009-1-git-send-email-dborkman@redhat.com>
	<20130802102229.GB1586@minipsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42257 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242Ab3HBV4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 17:56:43 -0400
In-Reply-To: <20130802102229.GB1586@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 2 Aug 2013 12:22:29 +0200

> Fri, Aug 02, 2013 at 11:32:43AM CEST, dborkman@redhat.com wrote:
>>Commit 5c766d642 ("ipv4: introduce address lifetime") leaves the ifa
>>resource that was allocated via inet_alloc_ifa() unfreed when returning
>>the function with -EINVAL. Thus, free it first via inet_free_ifa().
>>
>>Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Reviewed-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks.
