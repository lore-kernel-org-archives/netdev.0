From: Jean-Mickael Guerin <jean-mickael.guerin@6wind.com>
Subject: Re: [PATCH 7/13] [RFC] [IPV6] Move source address selection into
 route lookup.
Date: Tue, 17 Oct 2006 10:01:24 +0200
Message-ID: <45348DD4.4000600@6wind.com>
References: <4534201D.7070002@tcs.hut.fi> <20061016.222223.26532234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, yoshfuji@linux-ipv6.org, tgraf@suug.ch,
	kim.nordlund@nokia.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:13843 "EHLO
	proxy.6wind.com") by vger.kernel.org with ESMTP id S932223AbWJQIBm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 04:01:42 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061016.222223.26532234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Ville Nuorvala <vnuorval@tcs.hut.fi>
> Date: Tue, 17 Oct 2006 03:13:17 +0300
>
>> This patch moves the normal source address selection from
>> ip6_dst_lookup() into ip6_pol_route_output(), but shouldn't
>> change the routing or source address selection behavior in
>> any way.
>>
>> Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
>
> Although this conversion is very clean and the next patch
> is very logic, I'm going to hold on all patches from 7 onward
> so there is some time for some discussion of the RFC'ness
> of them :-)
>
With regard to RFC'ness, passing self tests TAHI "Ready Logo 2" with 
SUBTREE
turned on could be a valuable feedback.

Jean-Mickael

