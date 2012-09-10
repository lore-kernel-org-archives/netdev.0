From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Report user triggered expirations against the
 users socket
Date: Mon, 10 Sep 2012 15:34:51 -0400 (EDT)
Message-ID: <20120910.153451.799687655699800104.davem@davemloft.net>
References: <871uidj8so.fsf@xmission.com>
	<87pq5xhtky.fsf_-_@xmission.com>
	<504B307E.2030607@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, hadi@cyberus.ca
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32873 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758414Ab2IJTex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:34:53 -0400
In-Reply-To: <504B307E.2030607@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Sat, 08 Sep 2012 07:48:14 -0400

> On 12-09-08 03:17 AM, Eric W. Biederman wrote:
>> When a policy expiration is triggered from user space the request
>> travles through km_policy_expired and ultimately into
>> xfrm_exp_policy_notify which calls build_polexpire.  build_polexpire
>> uses the netlink port passed to km_policy_expired as the source port
>> for
>> the netlink message it builds.
>>
>> When a state expiration is triggered from user space the request
>> travles
>> through km_state_expired and ultimately into xfrm_exp_state_notify
>> which
>> calls build_expire.  build_expire uses the netlink port passed to
>> km_state_expired as the source port for the netlink message it builds.
>>
>> Pass nlh->nlmsg_pid from the user generated netlink message that
>> requested the expiration to km_policy_expired and km_state_expired
>> instead of current->pid which is not a netlink port number.
>>
>> Cc: Jamal Hadi Salim <hadi@cyberus.ca>
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>
> 
> I suppose.
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied to net-next, thanks.
