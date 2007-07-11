From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] IPROUTE2: Fix bug  in display of ipv6 cloned/cached routes
Date: Wed, 11 Jul 2007 20:46:22 +0200
Message-ID: <4695257E.8080105@trash.net>
References: <1184179063.16607.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59593 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755509AbXGKSq0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 14:46:26 -0400
In-Reply-To: <1184179063.16607.9.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> This patch fixes a bug in the 'ip' command to display 
> IPv6 cloned routes.
>   ip -6 route ls cache
> returns empty even when there are cloned routes because of
> of a missing else in print_route() routine.


Looks good. The ip6_multiple_tables case seems to be missing
filtering for cloned entries entirely, would you mind adding
that as well?


