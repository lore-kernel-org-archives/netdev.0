From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 1/3] igmp: fix return value of some functions
Date: Mon, 10 Jun 2013 11:07:33 +0800
Message-ID: <1370833653.11543.3.camel@cr0>
References: <1370689003.868.3.camel@cr0>
	, <1370485211-11498-1-git-send-email-amwang@redhat.com>
		 <OFF0DFA533.AF670FB8-ON85257B82.006E0B5C-85257B82.006F58EF@us.ibm.com>
	 <OF76532841.5DDD0996-ON87257B85.000C25DF-87257B85.000C25E6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev-owner@vger.kernel.org, netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751026Ab3FJDHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 23:07:44 -0400
In-Reply-To: <OF76532841.5DDD0996-ON87257B85.000C25DF-87257B85.000C25E6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-08 at 20:12 -0600, David Stevens wrote:
> >From: Cong Wang <amwang@redhat.com>
> 
> >   Good point! I will convert the such return value to
> >documented ones, for example, EINVAL.  Thanks!
> 
> You're also taking things that were not treated as errors
> before, and now returning an error. For example, removing
> a source not in the list.
> 
> Unless POSIX requires these to be treated as errors, and
> that should be quoted, I think the 8 or 9 years of returning
> "0" for these cases means we must continue to. Existing
> programs that have always done this with a zero return
> will start getting errors where they didn't before.
> 
> Also, though it's been a long time, I believe the original code
> did return errors in those cases (which is why the code is there)
> and was changed to return 0, presumably for POSIX compliance.

Are you suggesting to just make ip_mc_leave_src() void?

Thanks.
