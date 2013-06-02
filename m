From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 1/4] Clean up indentation in net/ipv6/transp_v6.h
Date: Sat, 01 Jun 2013 20:06:08 -0700
Message-ID: <1370142368.2086.6.camel@joe-AO722>
References: <1370048750-28441-1-git-send-email-lorenzo@google.com>
	 <1370049940.10556.100.camel@joe-AO722>
	 <20130601.195806.2024506377665086082.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: lorenzo@google.com, netdev@vger.kernel.org, edumazet@google.com,
	yoshfuji@linux-ipv6.org, segoon@openwall.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51700 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750779Ab3FBDGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jun 2013 23:06:10 -0400
In-Reply-To: <20130601.195806.2024506377665086082.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-01 at 19:58 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Fri, 31 May 2013 18:25:40 -0700
> 
> > externs aren't useful here and I suggest prototypes like
> > int ipv6_exthdrs_init(void);
> 
> But this is the format used by the entire header file, all functions
> are declared extern.
> 
> It is not reasonable to ask him to change this.  It's a seperate
> cleanup, and that's assuming we actually agree to remove the externs.
> I honestly see no reason to, they are harmless, and given that it's
> just pure churn.

<shrug>

How is that churn different than the entire patch?

extern _isn't_ useful and the tabbed indentation is
different than most all includes.

1 tab or 2 isn't a big thing.

I think cleanup patches like this should strive for
consistency with whatever preferred style exists.

If a cleanup only patch is proffered, I think the
cleanup should be as complete as possible.
