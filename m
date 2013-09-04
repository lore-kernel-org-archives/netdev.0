From: David Miller <davem@davemloft.net>
Subject: Re: ICMPv6: treat dest unreachable codes 5 and 6 as EACCES, not
 EPROTO
Date: Tue, 03 Sep 2013 22:12:24 -0400 (EDT)
Message-ID: <20130903.221224.1469516113963270002.davem@davemloft.net>
References: <20130830091844.GA2706@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752165Ab3IDCM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 22:12:26 -0400
In-Reply-To: <20130830091844.GA2706@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Fri, 30 Aug 2013 11:18:45 +0200

> RFC 4443 has defined two additional codes for ICMPv6 type 1 (destination
> unreachable) messages:
>         5 - Source address failed ingress/egress policy
> 	6 - Reject route to destination
> 
> Now they are treated as protocol error and icmpv6_err_convert() converts them
> to EPROTO.
> 
> RFC 4443 says:
> 	"Codes 5 and 6 are more informative subsets of code 1."
> 
> Treat codes 5 and 6 as code 1 (EACCES)
> 
> Btw, connect() returning -EPROTO confuses firefox, so that fallback to
> other/IPv4 addresses does not work:
> https://bugzilla.mozilla.org/show_bug.cgi?id=910773
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>

Applied and queued up for -stable, thanks.
