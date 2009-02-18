From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Wed, 18 Feb 2009 16:14:07 +0100
Message-ID: <499C25BF.4060203@trash.net>
References: <20090212171245.GA15025@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55308 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752652AbZBRPOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 10:14:10 -0500
In-Reply-To: <20090212171245.GA15025@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov wrote:
> +config IP_NF_MATCH_OSF
> +	tristate '"osf" match support'
> +	depends on NETFILTER_ADVANCED && CONNECTOR

I can't see any further code issues than those already pointed
out, however I would really like to see the use of connector go.
We do already have nfnetlink specifically for netfilter that can
do the same thing, I see no reason to use connector instead.

