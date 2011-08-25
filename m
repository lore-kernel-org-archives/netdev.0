From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Thu, 25 Aug 2011 08:19:29 -0700
Message-ID: <CA+mtBx8nyODqV155J0kUtfFQW3gy9O9pKKXZuwCN+nSqiijX6A@mail.gmail.com>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	<1312808784.17202.39.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:61734 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008Ab1HYPTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 11:19:32 -0400
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p7PFJVqK018276
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:19:31 -0700
Received: from ywb5 (ywb5.prod.google.com [10.192.2.5])
	by wpaz21.hot.corp.google.com with ESMTP id p7PFJOGh002673
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:19:30 -0700
Received: by ywb5 with SMTP id 5so2306682ywb.12
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:19:30 -0700 (PDT)
In-Reply-To: <1312808784.17202.39.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> For wired connections I think the big deal is in improved
> runtime memory saving (your perf numbers are kinda ok).
> The challenge is going to be with wireless where the underlying
> bandwidth changes (and therefore the optimal queue size varies
> more frequently). The problem with active queue management is
> getting the feedback loop to be more accurate and i think there
> will be challenges with wired devices.

The important characteristic (for us at least) will be reduced latency
for high priority packets (for NICs that don't support qos multiQ.  I
do have data showing those benefits, but it's a little old.  I will
have something to present at LPC.

> I notice that you dont have any wireless devices;
> but it would be nice for someone to check this out on wireless.
> CCing Johannes - maybe he has some insight.
>
Yeah, these scare me ;-)

> cheers,
> jamal
>
>
>
>
