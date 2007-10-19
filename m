From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: multicast: bug or "feature"
Date: Fri, 19 Oct 2007 14:43:54 -0400
Message-ID: <4718FAEA.8060304@hp.com>
References: <OF743FE77C.521201D4-ON88257379.00608213-88257379.00613A32@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:58665 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936114AbXJSSoj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 14:44:39 -0400
In-Reply-To: <OF743FE77C.521201D4-ON88257379.00608213-88257379.00613A32@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> I don't know why you'd want it to be different for multicasting. If you
> want to hear your own multicasts, you should use MULTICAST_LOOP;
> hearing them off the wire indicates all the same bad things -- a forger,
> a duplicate address or a routing loop. Those aren't any better for
> multicasting than they are for unicasting, that I can see.
> 
> Why would you want that to be delivered, other than (apparently)
> to test the multicast capability of a pair of interfaces while using
> only 1 machine?
> 

I don't really, but the customer is complaining.  The customer is 
transitioning from BSD to Linux, but wishes to support both.  The
behaviors are different.  Client applications that assume certain
behavior on BSD, do not work on Linux.

It's just a pain.  I was more wondering why v4 and v6 did things 
different in this case.

-vlad
