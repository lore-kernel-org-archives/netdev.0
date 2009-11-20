From: Joe Perches <joe@perches.com>
Subject: Re: [net-next-2.6 PATCH v7 5/7 RFC] TCPCT part 1e: implement
 socket option TCP_COOKIE_TRANSACTIONS
Date: Fri, 20 Nov 2009 12:54:36 -0800
Message-ID: <1258750476.28239.63.camel@Joe-Laptop.home>
References: <4B06A1FF.8000202@gmail.com> <4B06AC2C.3070102@gmail.com>
	 <20091120.092651.254794724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: william.allen.simpson@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1066 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755714AbZKTUyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2009 15:54:32 -0500
In-Reply-To: <20091120.092651.254794724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-11-20 at 09:26 -0800, David Miller wrote:
> From: William Allen Simpson <william.allen.simpson@gmail.com>
> > +		ctd.tcpct_flags = (tp->rx_opt.cookie_in_always
> > +				   ? TCP_COOKIE_IN_ALWAYS : 0)
> > +				| (tp->rx_opt.cookie_out_never
> > +				   ? TCP_COOKIE_OUT_NEVER : 0);
> 
> "?" should be at end of previous line not at beginning of
> next one, please fix this up.

Perhaps the ? position is taster's choice.

(false positives exist)

$ grep -rP --include=*.[ch] "^\s*\?" * | wc -l
884

$ grep -rP --include=*.[ch] -h "\?\s*$" * | \
  grep -vP "^\s*\*" | grep -vP "(//|/\*)" | wc -l
2968


