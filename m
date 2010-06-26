From: Simon Horman <horms@verge.net.au>
Subject: Re: nonlocal_bind & IPv6
Date: Sat, 26 Jun 2010 23:25:40 +1000
Message-ID: <20100626132540.GA30133@verge.net.au>
References: <201006252043.45581.michal.humpula@hudrydum.cz>
 <30fe1fa984e52f4cca318e54f9d97a21@chewa.net>
 <201006252110.08508.michal.humpula@hudrydum.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?B?UsOpbWk=?= Denis-Courmont <remi@remlab.net>,
	netdev@vger.kernel.org
To: Michal Humpula <michal.humpula@hudrydum.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:35847 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755427Ab0FZNyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jun 2010 09:54:33 -0400
Content-Disposition: inline
In-Reply-To: <201006252110.08508.michal.humpula@hudrydum.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 25, 2010 at 09:10:08PM +0200, Michal Humpula wrote:
> Ok, more detail example. 
> 
> Let on each node be an apache (just for an example), and you configure
> VirtualHost for specific IP. So when node A fails, keepalived move IP to
> the node B and everything is still running. No need for restart of apache
> or anything else. There is a probably a better solution, but I can't find
> anything more simple than the posted patch:)

Not an answer to your original question, but that sounds like a problem
that can be resolved using IP_TRANSPARENT. Although I have only tested
that feature in conjunction with IPv4, it seems to support IPv6 too.

See Documentation/networking/tproxy.txt

