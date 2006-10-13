From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [IPv6] rules: Use RT6_LOOKUP_F_HAS_SADDR and fix source based
 selectors
Date: Fri, 13 Oct 2006 11:58:44 +0300
Message-ID: <452F5544.6080407@tcs.hut.fi>
References: <20061012094124.GH12964@postel.suug.ch>	<20061012.185551.31808845.yoshfuji@linux-ipv6.org> <20061012.191630.35017097.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, tgraf@suug.ch, netdev@vger.kernel.org,
	kim.nordlund@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:13330 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1750743AbWJMI6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2006 04:58:31 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061012.191630.35017097.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/13/06 05:16, David Miller wrote:
> From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Date: Thu, 12 Oct 2006 18:55:51 +0900 (JST)
> 
>> I tend to agree.  Ville, do you agree?
> 
> I'll wait for Ville's response before applying this.
> Otherwise, I think the change looks fine.


Acked-by: Ville Nuorvala <vnuorval@tcs.hut.fi>

This doesn't however solve all the problems with source address based
routing. For example we always need to have a valid source address when
we cow or copy a route in ip6_pol_route_output() etc. In my original
solution I moved the source address selection functionality into the
route lookup code as the two very much depend on each other and can't
IMO really be done separately.

I'm currently working on a patch for all of this, but please go ahead
and apply Thomas's and Kim's patch.

I'll try to post an initial RFC version of my patch later today.

Regards,
Ville



