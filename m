From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH 1/4] Prefix List against 2.5.73
Date: Wed, 16 Jul 2003 04:21:33 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307160021.EAA10195@dub.inr.ac.ru>
References: <3F14492C.30708@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, davem@redhat.com, netdev@oss.sgi.com,
   linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: krkumar@us.ibm.com (Krishna Kumar)
In-Reply-To: <3F14492C.30708@us.ibm.com> from "Krishna Kumar" at éÀÌ 15, 2003 11:34:20 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> the two sets of #defines (if_flags & ifa_flags since they intersect). I propose
> changing the values of IFA_PERM/TENT/DEPRE/SECOND,

This is almost impossible, it is an old public API.

> which is the first bit of the field, but let me know if this is not acceptable.

Select yourself: either IFA_IFFLAGS or translated flags in ifa_flags.
I prefer the second way just because it is too unpleasant to add
a new attribute for sake of two bits with no visible candidates
to use remaining ones.


> OK, I can change that to give a filter. Is it OK to add the filter to rtm_flags ?
> I was thinking of adding RTM_F_PREFIX, and rt6_dump_route() can pass this information
> to rt6_fill_node() which does filtering of routes based on whether this flag is set
> or not. Did I understand you correctly here ?

Perfectly!


> I can remove the check completely and introduce a new flag RTF_PREFIX_RT to distinguish
> between various route types.
> 
> Are these modifications OK ?

Yes, I would prefer this... Actually, it is mostly to leave possibility
to override this bit administratively. :-) If you insist this is totally
illegal and the rule must be hardwired, new flag is really redundant.

Alexey
