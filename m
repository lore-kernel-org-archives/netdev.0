From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Fw: [Bug 18212] New: force_igmp_version ignored when a IGMPv3 query
 received (+1 line patch)
Date: Tue, 14 Sep 2010 14:20:40 -0700
Message-ID: <OF1A09F28B.15E7E7BC-ON8825779E.00741A65-8825779E.007540E3@us.ibm.com>
References: <20100910091936.75eabbf6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Herbert Xu <herbert@gondor.hengli.com.au>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:33795 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205Ab0INVUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 17:20:45 -0400
In-Reply-To: <20100910091936.75eabbf6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 09/10/2010 09:19:36 AM:

> 
> https://bugzilla.kernel.org/show_bug.cgi?id=18212
> 
>            Summary: force_igmp_version ignored when a IGMPv3 query
>                     received (+1 line patch)

> 
> Created an attachment (id=29512)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=29512)
> fix force_igmp_version v3 query problem
> 
> After all these years, it turns out that the
>     /proc/sys/net/ipv4/conf/*/force_igmp_version
> parameter isn't fully implemented.

        I don't think it's correct to send a v2 response to a v3
query in any case. The question for answering v3 queries was
whether to answer them with a v3 report, or to drop them and
ignore them when force_igmp_version==2. I chose to respond,
but I can see the case for dropping it too. I don't agree that
a v3 query should be answered with a v2 resport (a real v2
host would drop it).

                                                        +-DLS

