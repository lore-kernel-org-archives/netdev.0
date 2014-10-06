From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: validate_xmit_vlan() is static
Date: Mon, 06 Oct 2014 11:44:02 -0700
Message-ID: <1412621042.2916.29.camel@joe-AO725>
References: <1412619987.11091.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Dan Carpenter <error27@gmail.com>,
	Josh Triplett <josh@joshtriplett.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0040.hostedemail.com ([216.40.44.40]:60771 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753036AbaJFSoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 14:44:08 -0400
In-Reply-To: <1412619987.11091.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 11:26 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Marking this as static allows compiler to inline it.

Found by inspection or another tool?

Wasn't there some tool to look for non-static functions
that are not called externally that could/should be
converted to static?
