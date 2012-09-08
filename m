From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH] xfrm: Report user triggered expirations against the users
 socket
Date: Sat, 08 Sep 2012 07:48:14 -0400
Message-ID: <504B307E.2030607@mojatatu.com>
References: <87a9x1j9qh.fsf@xmission.com> <871uidj8so.fsf@xmission.com> <87pq5xhtky.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:43441 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143Ab2IHLs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2012 07:48:27 -0400
Received: by ieje11 with SMTP id e11so529609iej.19
        for <netdev@vger.kernel.org>; Sat, 08 Sep 2012 04:48:26 -0700 (PDT)
In-Reply-To: <87pq5xhtky.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-09-08 03:17 AM, Eric W. Biederman wrote:
> When a policy expiration is triggered from user space the request
> travles through km_policy_expired and ultimately into
> xfrm_exp_policy_notify which calls build_polexpire.  build_polexpire
> uses the netlink port passed to km_policy_expired as the source port for
> the netlink message it builds.
>
> When a state expiration is triggered from user space the request travles
> through km_state_expired and ultimately into xfrm_exp_state_notify which
> calls build_expire.  build_expire uses the netlink port passed to
> km_state_expired as the source port for the netlink message it builds.
>
> Pass nlh->nlmsg_pid from the user generated netlink message that
> requested the expiration to km_policy_expired and km_state_expired
> instead of current->pid which is not a netlink port number.
>
> Cc: Jamal Hadi Salim <hadi@cyberus.ca>
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>

I suppose.
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>


cheers,
jamal
