From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: skb_set_dev do not unconditionally drop ref to dst
Date: Wed, 9 May 2012 12:48:03 +0200
Message-ID: <20120509104803.GA52076@tuxmaker.boeblingen.de.ibm.com>
References: <1335765093.2296.4.camel@edumazet-glaptop> <20120502055018.GA50959@tuxmaker.boeblingen.de.ibm.com> <1335941961.22133.48.camel@edumazet-glaptop> <20120503.022837.2021054007853235758.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, arnd@arndb.de, linux-s390@vger.kernel.org,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:42759 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab2EIKsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 06:48:07 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Wed, 9 May 2012 11:48:05 +0100
Content-Disposition: inline
In-Reply-To: <20120503.022837.2021054007853235758.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 03, 2012 at 02:28:37AM -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 02 May 2012 08:59:21 +0200
> 
> > If Arnd doesnt care to even reply, we can just revert his buggy
> > patch, instead of trying to understand and fix all issues.
> 
> Agreed, it's the best sounding solution by far.
Hi Dave,

looks like discussion is done and everybody is ok with reverting
Arnds patch. Can you revert commit 8a83a00b0735190384a348156837918271034144 ?
Thx

Fran ?
Thx

Frank

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
