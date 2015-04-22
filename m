From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] mpls: ABI changes for security and correctness
Date: Tue, 21 Apr 2015 22:12:16 -0400 (EDT)
Message-ID: <20150421.221216.1827780895297926700.davem@davemloft.net>
References: <1429051503-31287-1-git-send-email-rshearma@brocade.com>
	<1429648467-8449-1-git-send-email-rshearma@brocade.com>
	<87d22xm2dl.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rshearma@brocade.com, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273AbbDVCMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 22:12:17 -0400
In-Reply-To: <87d22xm2dl.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 21 Apr 2015 19:29:42 -0500

> Robert Shearman <rshearma@brocade.com> writes:
> 
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
> I don't like the difference in default between loopback and everything
> else.  That just seems like an extra arbitrary rule.
> 
> Otherwise:
> Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> Not that I expect Dave Miller is taking patches during the merge window.

Eric, you say you disagree with the loopback vs. everything else
behavior, yet you're ACK'ing this.

Please don't say something like that because it is confusing and
I can't tell what you want me to do.

If you're willing to accept the series as is, say is: "Even though
I disagree with X, I'm ok with this series for now."

If you want changes before the series gets applied: "I want X
changed to Y, and with that I give my ACK."

Thanks.
