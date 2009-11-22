From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH v7 5/7 RFC] TCPCT part 1e: implement
 socket option TCP_COOKIE_TRANSACTIONS
Date: Sat, 21 Nov 2009 23:10:48 -0800
Message-ID: <1258873848.16503.12.camel@Joe-Laptop.home>
References: <4B06A1FF.8000202@gmail.com>	<4B06AC2C.3070102@gmail.com>
	 <20091120.092651.254794724.davem@davemloft.net>  <4B08D967.80003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1077 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751101AbZKVHKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Nov 2009 02:10:43 -0500
In-Reply-To: <4B08D967.80003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-11-22 at 01:25 -0500, William Allen Simpson wrote:
> David Miller wrote:
> > From: William Allen Simpson <william.allen.simpson@gmail.com>
> > Date: Fri, 20 Nov 2009 09:48:12 -0500
> >> +		if (ctd.tcpct_used > 0
> >> +		 || (tp->cookie_values == NULL
> >> +		  && (sysctl_tcp_cookie_size > 0
> >> +		   || ctd.tcpct_cookie_desired > 0
> >> +		   || ctd.tcpct_s_data_desired > 0))) {
> > Please fix the conditional coding style, and the alignment of
> > the lines, it's not right here.
> David, would indentation of 2 or 4 be preferable here?

Hi William.

I think the rather significantly majority style, especially
for net/... is to use || and && at the end of the line rather
than the start and it should be used.

Treewide:

$ grep -rP --include=*.[ch] "(\|\||\&\&)\s*$" * | wc -l
34180

$ grep -rP --include=*.[ch] "^\s*(\|\||\&\&)" * | wc -l
7855

net: 3859 to 382 (more than 10:1, so it's the one to follow)
drivers/net: 4610 to 666

Besides, it's the one David wants...

cheers, Joe

