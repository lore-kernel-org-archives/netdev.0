From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCH net-next 2/3] ipv6: mld: do not overwrite uri when receiving
 an mldv2 query
Date: Thu, 25 Sep 2014 19:29:25 -0400
Message-ID: <5424A555.5020303@oracle.com>
References: <1411455828-5196-1-git-send-email-dborkman@redhat.com> <1411455828-5196-3-git-send-email-dborkman@redhat.com> <54243C89.6060405@oracle.com> <542475E3.6030508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44804 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753161AbaIYX3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 19:29:32 -0400
In-Reply-To: <542475E3.6030508@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/25/2014 04:06 PM, Daniel Borkmann wrote:

> from that query; both specifications also specify different default values for
> URI, where we would have already overwritten a pre-configured URI default value
> for v1 when we previously received a v2 query. While we have tunable for IPv4
> case via commit 2690048c01f32 ("net: igmp: Allow user-space configuration of
> igmp unsolicited report interval") and for IPv6 case via commit fc4eba58b4c1
> ("ipv6: make unsolicited report intervals configurable for mld"), this renders
> any admin provided IPv6 specific configuration useless.


PS -

I didn't address this part -- I don't object at all to resetting the value
when doing a version switch, or even if we lose a querier for a while. That
isn't what your patch does.

						+-DLS
