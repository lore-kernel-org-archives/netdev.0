From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] mpls: ABI changes for security and correctness
Date: Wed, 22 Apr 2015 14:25:12 -0400 (EDT)
Message-ID: <20150422.142512.859593495981790890.davem@davemloft.net>
References: <1429648467-8449-1-git-send-email-rshearma@brocade.com>
	<1429697679-13767-1-git-send-email-rshearma@brocade.com>
	<87wq14jek1.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbbDVSZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 14:25:14 -0400
In-Reply-To: <87wq14jek1.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 22 Apr 2015 11:47:10 -0500

> Robert Shearman <rshearma@brocade.com> writes:
> 
>> V2:
>>  - don't treat loopback interfaces specially by enabling mpls by
>>    default
>>
>> These changes make mpls not be enabled by default on all
>> interfaces when in use for security, along with ensuring that a label
>> not valid as an outgoing label can be added in mpls routes.
>>
>> This series contains three ABI/behaviour-affecting changes which have
>> been split out from "[PATCH net-next v4 0/6] mpls: Behaviour-changing
>> improvements" without any further modification. These changes need to
>> be considered for 4.1 otherwise we'll be stuck with the current
>> behaviour/ABI forever.
> 
> Thanks.
> 
> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> These patches all look good.  If these patches can make it into 4.1 so
> we don't have a stable release without the new net/mpls/conf/<dev>/input
> sysctl that would minimize disruption to users of the mpls code.

Series applied, thanks everyone.
