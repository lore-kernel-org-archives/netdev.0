From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: IFA_F_OPTIMISTIC is not supported?
Date: Fri, 8 Sep 2017 17:07:33 +0200
Message-ID: <20170908150733.GA21315@bistromath.localdomain>
References: <59b2a92f.G2i6Z3JSoznmqvuW%soohoon.lee@f5.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: soohoon.lee@f5.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56092 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751689AbdIHPHg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 11:07:36 -0400
Content-Disposition: inline
In-Reply-To: <59b2a92f.G2i6Z3JSoznmqvuW%soohoon.lee@f5.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-09-08, 10:29:03 -0400, soohoon.lee@f5.com wrote:
> rtm_newaddr masks off OPTIMISTIC.
> 
> inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
> ...
>         /* We ignore other flags so far. */
>         ifa_flags &= IFA_F_NODAD | IFA_F_HOMEADDRESS | IFA_F_MANAGETEMPADDR |
>                      IFA_F_NOPREFIXROUTE;
> 
> Is there any problem or not allowed?

I was planning to submit a patch to allow that soon (when net-next
reopens). While testing, I've found you need a few other small changes
once you allow userspace to set the optimistic flag on addresses.


Thanks,

-- 
Sabrina
