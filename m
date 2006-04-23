From: Florian Zumbiehl <florz@gmx.de>
Subject: Re: TCP not retransmitting supposedly lost segment
Date: Mon, 24 Apr 2006 01:56:09 +0200
Message-ID: <20060423235609.GB17254@florz.florz.dyndns.org>
References: <20060406171926.GA8142@florz.florz.dyndns.org> <20060410010005.GA9282@florz.florz.dyndns.org> <20060423122718.GA16504@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dialin111053.justdsl.de ([85.25.111.53]:43017 "EHLO
	rain.florz.dyndns.org") by vger.kernel.org with ESMTP
	id S1751464AbWDWX4R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 19:56:17 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060423122718.GA16504@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> This tells us that the kernel was indeed retransmitting but the
> packet didn't make it out of the interface according to your
> tcpdump.

Well, at least the tcp part of it, it seems, yep. The debugging I've
done so far also seems to confirm that the problem is somewhere beyond
the tcp code, but I don't have any real clue yet ...

> Do you have any firewall rules? Any tc rules?

ip6tables rules, yes, but none in the filter/OUTPUT chain (and policy
ACCEPT, of course) and only counting rules in mangle/OUTPUT (using
only user-defined chains and target RETURN, with policy ACCEPT, once
again).

So i'd wonder if that'd be the cause of the problem.

BTW, other TCP/IPv6 (IRC) connections active at the same time work
without problems - but each of them fails in that way now and
then ...

Well, all in all that probably doesn't help you much - but any
hints as to how/where to further debug are welcome :-)

Florian
