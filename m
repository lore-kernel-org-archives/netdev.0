From: Michal Humpula <michal.humpula@hudrydum.cz>
Subject: Re: nonlocal_bind & IPv6
Date: Sat, 26 Jun 2010 22:42:16 +0200
Message-ID: <201006262242.16346.michal.humpula@hudrydum.cz>
References: <201006252043.45581.michal.humpula@hudrydum.cz> <201006252110.08508.michal.humpula@hudrydum.cz> <20100626132540.GA30133@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hudrydum.cz ([88.208.90.178]:47776 "EHLO hudrydum.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753187Ab0FZUmW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jun 2010 16:42:22 -0400
In-Reply-To: <20100626132540.GA30133@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 26 of June 2010 15:25:40 Simon Horman wrote:
> On Fri, Jun 25, 2010 at 09:10:08PM +0200, Michal Humpula wrote:
> > Ok, more detail example.
> > 
> > Let on each node be an apache (just for an example), and you configure
> > VirtualHost for specific IP. So when node A fails, keepalived move IP to
> > the node B and everything is still running. No need for restart of apache
> > or anything else. There is a probably a better solution, but I can't find
> > anything more simple than the posted patch:)
> 
> Not an answer to your original question, but that sounds like a problem
> that can be resolved using IP_TRANSPARENT. Although I have only tested
> that feature in conjunction with IPv4, it seems to support IPv6 too.
> 
> See Documentation/networking/tproxy.txt

Thanks for redirection. I don't think that IP_TRANSPARENT is suited well for my problem, 
but I did find the IP_FREEBIND in the process. Unfortunately it seems that both are 
enabled only for IPv4 and IPv6 mapped addresses. 

So, is there any reason why IP_FREEBIND or nonlocal_bind sysctl is not in current IPv6 
kernel implementation?

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
