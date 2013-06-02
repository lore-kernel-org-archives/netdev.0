From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 1/4] Clean up indentation in net/ipv6/transp_v6.h
Date: Sat, 01 Jun 2013 20:52:15 -0700
Message-ID: <1370145135.2086.10.camel@joe-AO722>
References: <1370048750-28441-1-git-send-email-lorenzo@google.com>
	 <1370049940.10556.100.camel@joe-AO722>
	 <20130601.195806.2024506377665086082.davem@davemloft.net>
	 <1370142368.2086.6.camel@joe-AO722>
	 <CAKD1Yr0rX4fR-fQfvZ_KpLbAf0+wehR=SmXzJtbPPGmKXTd7Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36160 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750856Ab3FBDwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Jun 2013 23:52:17 -0400
In-Reply-To: <CAKD1Yr0rX4fR-fQfvZ_KpLbAf0+wehR=SmXzJtbPPGmKXTd7Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-02 at 12:44 +0900, Lorenzo Colitti wrote:
> On Sun, Jun 2, 2013 at 12:06 PM, Joe Perches <joe@perches.com> wrote:
> > How is that churn different than the entire patch?
> 
> I changed the indentation because patch 2 in the set introduced
> another function and I didn't know how to indent it. Currently, some
> declarations are not tab-indented, some are tab-indented to column 40,
> and some are tab-indented to column 32. I thought that while I was at
> it I might change them to be consistent. So this patch changes it so
> they're all tab-indented to column 24; I thought that was more
> readable.
> 
> That said, I don't have strong feelings about the indentation - my
> main goal here was removing code duplication. If I reverted the
> indentation patch and just aligned the new function to the function
> above it, would that be better?

Hey Lorenzo.

I think you should use whatever you think appropriate without
trying to fix the other function prototypes.

Otherwise, I'd do what I suggested in my first email.

cheers, Joe
