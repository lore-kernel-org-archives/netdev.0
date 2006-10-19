From: Mitsuru Chinen <mitch@jp.ibm.com>
Subject: Re: (usagi-core 31424) Re: [PATCH 7/13] [RFC] [IPV6] Move source
 address selection into route lookup.
Date: Thu, 19 Oct 2006 19:25:21 +0900
Message-ID: <45375291.4080607@jp.ibm.com>
References: <20061016.222223.26532234.davem@davemloft.net>	<45348DD4.4000600@6wind.com>	<20061017.175231.45194288.yoshfuji@linux-ipv6.org> <20061018.230850.91573842.yoshfuji@linux-ipv6.org> <4536E279.1090003@jp.ibm.com> <453743C0.4000701@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, davem@davemloft.net, tgraf@suug.ch,
	kim.nordlund@nokia.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jean-mickael.guerin@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:61150 "EHLO
	e35.co.us.ibm.com") by vger.kernel.org with ESMTP id S1161384AbWJSKZf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Oct 2006 06:25:35 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9JAPWXG005884
	for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 06:25:32 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9JAPVwD513646
	for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 04:25:31 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9JAPUcl028720
	for <netdev@vger.kernel.org>; Thu, 19 Oct 2006 04:25:31 -0600
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <453743C0.4000701@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Ville,

Ville Nuorvala wrote:
> Mitsuru-san,
> 
> could you apply patch #12 and rerun the test? I think this particular
> problem is caused by the routing cache entry not having a valid source
> address in the first place. As ip6_dst_lookup() doesn't do the source
> address lookup anymore, it is critical that we only store cache entries
> with complete address data for both destination and source.
> 
> These two patches apparently shouldn't have been split in the first
> place. Sorry!

I'm afraid patch #12 doesn't work for this issue.

Although I applied patch #12, I still got fails.
The test log is the same as the last one.
When I applied all patches, I got fails, either.

Best Regards,
-- 
Mitsuru Chinen <mitch@jp.ibm.com>

