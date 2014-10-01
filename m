From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] udp: increment UDP_NO_PORTS when dropping unmatched
 multicasts
Date: Wed, 01 Oct 2014 09:32:43 -0700
Message-ID: <542C2CAB.2030501@hp.com>
References: <20141001151921.7131E29003A2@tardy> <542C23AA.6060505@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: David L Stevens <david.stevens@oracle.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hp.com ([15.201.208.54]:60684 "EHLO
	g4t3426.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbaJAQcq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 12:32:46 -0400
In-Reply-To: <542C23AA.6060505@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/01/2014 08:54 AM, David L Stevens wrote:
> I think this would have the unpleasant side-effect of incrementing a drop
> stat when we have not joined a multicast group that has UDP traffic, but the
> interface is in promiscuous mode. Also, false positives for the multicast
> address filter.
>
> Multicast address filters are not perfect matches, so it is "normal" to receive
> multicasts and broadcasts that are not addressed to our host. I'm not sure those
> should count as "noports" any more than traffic addressed to someone else's IP
> address if we're in promiscuous mode should.
>
> In the multicast case, it would really only make sense if we have actually joined
> the group it's addressed to.

Do you think an "ignored" statistic would be appropriate then?

rick
