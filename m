From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Allowing more than 64k connections and heavily optimize bind(0) time.
Date: Mon, 12 Jan 2009 12:27:56 +0300
Message-ID: <20090112092756.GA29498@ioremap.net>
References: <20090110.232019.98466627.davem@davemloft.net> <20090111125206.GA24173@ioremap.net> <200901111503.10736.denys@visp.net.lb> <20090111.230138.237917213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:36985 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753899AbZALJ16 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 04:27:58 -0500
Content-Disposition: inline
In-Reply-To: <20090111.230138.237917213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 11, 2009 at 11:01:38PM -0800, David Miller (davem@davemloft.net) wrote:
> Ok, I applied Evegniy's patch, but it didn't even come WITHIN A MILE
> of applying to the current tree.  Eric Dumazet's RCU hash table
> changes and net namespace macro modifications destroyed all of the
> context and content in these patches.  It was one huge reject, even
> with dumb patch.

Thank you David.

> As I just have been told, it results in this strange behaviour:
> $ grep -n :60013 netstat.res
> 33101:tcp        0      0 local1:60013       remote:80       ESTABLISHED
> 33105:tcp        0      0 local1:60013       remote:80       ESTABLISHED
> 52084:tcp        0      0 local2:60013       remote:80       ESTABLISHED
> 52085:tcp        0      0 local2:60013       remote:80       ESTABLISHED
> 58249:tcp        0      0 local3:60013       remote:80       ESTABLISHED
> 
> it is yet to resolve what it is and how much harm it brings :)

It should be already resolved in the patch :)

-- 
	Evgeniy Polyakov
