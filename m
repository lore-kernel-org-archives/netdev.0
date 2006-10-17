From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 9/13] [SCTP] Merge IPv4 and IPv6 versions of get_saddr()
 with their corresponding get_dst().
Date: Tue, 17 Oct 2006 15:42:55 -0700
Message-ID: <45355C6F.90701@us.ibm.com>
References: <453421AD.1010906@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:10889 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750990AbWJQWnG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 18:43:06 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9HMh65Z010225
	for <netdev@vger.kernel.org>; Tue, 17 Oct 2006 18:43:06 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9HMh42x143200
	for <netdev@vger.kernel.org>; Tue, 17 Oct 2006 16:43:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9HMh31s031028
	for <netdev@vger.kernel.org>; Tue, 17 Oct 2006 16:43:04 -0600
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <453421AD.1010906@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ville Nuorvala wrote:
> As the IPv6 route lookup now also returns the selected source address
> there is no need for a separate source address lookup. In fact, the
> source address selection needs to be moved to get_dst() because the
> selected IPv6 source address isn't always stored in the route.
> Sometimes this makes it impossible to guess the correct address later on.
>
>   
I remember having  to do a separate call to ipv6_get_saddr() 
specifically because ip6_route_output()
didn't fill in the source address. Now if the route lookup also returns 
the source address, it looks logical
to remove the separate source address lookup. So i agree with the idea 
behind the patch.
I will review the patch in detail and try it out next week to see that 
it doesn't break SCTP
and  get back to you.
I guess this is targeted for 2.6.20. Is that right?

Thanks
Sridhar

