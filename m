From: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Subject: Re: [PATCH] IPv6: ipv6_addr_type() doesn't know about RFC4193 addresses
Date: Thu, 26 Jul 2007 14:00:43 -0400
Message-ID: <18088.57675.352324.783405@zeus.sw.starentnetworks.com>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
	<46A8D837.1030400@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Srinivas Akkipeddi <sakkiped@starentnetworks.com>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [12.38.223.190] ([12.38.223.190]:26748 "EHLO
	mail.sw.starentnetworks.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S933005AbXGZSBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 14:01:06 -0400
In-Reply-To: <46A8D837.1030400@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Arlott writes:
> But ULA's scope isn't global, shouldn't it be IPV6_ADDR_SCOPE_ORGLOCAL ?

Isn't ORGLOCAL defined for multicast only?

rfc4193 section 3.3 says:

> 3.3. Scope Definition
>    By default, the scope of these addresses is global.  That is, they
>    are not limited by ambiguity like the site-local addresses defined in
>    [ADDARCH]. 


-- 
Dave Johnson
Starent Networks

