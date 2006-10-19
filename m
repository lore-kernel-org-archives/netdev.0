From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: (usagi-core 31424) Re: [PATCH 7/13] [RFC] [IPV6] Move source
 address selection into route lookup.
Date: Thu, 19 Oct 2006 12:22:08 +0300
Message-ID: <453743C0.4000701@tcs.hut.fi>
References: <20061016.222223.26532234.davem@davemloft.net>	<45348DD4.4000600@6wind.com>	<20061017.175231.45194288.yoshfuji@linux-ipv6.org> <20061018.230850.91573842.yoshfuji@linux-ipv6.org> <4536E279.1090003@jp.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, davem@davemloft.net, tgraf@suug.ch,
	kim.nordlund@nokia.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, jean-mickael.guerin@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:20490 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1030360AbWJSJWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 05:22:10 -0400
To: Mitsuru Chinen <mitch@jp.ibm.com>
In-Reply-To: <4536E279.1090003@jp.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitsuru-san,

could you apply patch #12 and rerun the test? I think this particular
problem is caused by the routing cache entry not having a valid source
address in the first place. As ip6_dst_lookup() doesn't do the source
address lookup anymore, it is critical that we only store cache entries
with complete address data for both destination and source.

These two patches apparently shouldn't have been split in the first
place. Sorry!

Regards,
Ville
