From: "David S. Miller" <davem@davemloft.net>
Subject: Re: possible problem with TSO and ip_queue
Date: Wed, 10 May 2006 13:09:19 -0700 (PDT)
Message-ID: <20060510.130919.37497120.davem@davemloft.net>
References: <Pine.LNX.4.64.0605101815430.16614@nacho.alt.net>
	<20060510.124955.114056211.davem@davemloft.net>
	<Pine.LNX.4.64.0605102105290.3813@sheen.jakma.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ccaputo@alt.net, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:14242
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932277AbWEJUJu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 May 2006 16:09:50 -0400
To: paul@clubi.ie
In-Reply-To: <Pine.LNX.4.64.0605102105290.3813@sheen.jakma.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Jakma <paul@clubi.ie>
Date: Wed, 10 May 2006 21:07:31 +0100 (IST)

> Is there a better way to deal with TSO besides documenting:
> 
> "disable TSO on all interfaces which /ever/ potentially could be used
>   to reach TCP-MD5 authenticated BGP peers."
> 
> ?

When you have a rule installed that will add MD5, just mark
the route as not being TSO capable.

What's the problem?
