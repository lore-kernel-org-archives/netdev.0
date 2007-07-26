From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Lksctp-developers] [PATCH] IPv6: ipv6_addr_type() doesn't know
 about RFC4193 addresses
Date: Thu, 26 Jul 2007 14:10:33 -0400
Message-ID: <46A8E399.70806@hp.com>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>	<46A8D837.1030400@simon.arlott.org.uk> <18088.57675.352324.783405@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Simon Arlott <simon@fire.lp0.eu>, netdev@vger.kernel.org,
	Srinivas Akkipeddi <sakkiped@starentnetworks.com>,
	davem@davemloft.net, lksctp-developers@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:43978 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761718AbXGZSWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 14:22:23 -0400
In-Reply-To: <18088.57675.352324.783405@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Johnson wrote:
> Simon Arlott writes:
>> But ULA's scope isn't global, shouldn't it be IPV6_ADDR_SCOPE_ORGLOCAL ?
> 
> Isn't ORGLOCAL defined for multicast only?

Yes, it's only for multicast.  Unicast addresses only have
2 scopes any more: Global and Link-Local.

-vlad

> 
> rfc4193 section 3.3 says:
> 
>> 3.3. Scope Definition
>>    By default, the scope of these addresses is global.  That is, they
>>    are not limited by ambiguity like the site-local addresses defined in
>>    [ADDARCH]. 
> 
> 

