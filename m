From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/6] kcm: Kernel Connection Multiplexor (KCM)
Date: Tue, 24 Nov 2015 16:27:44 +0100
Message-ID: <20151124152744.GB20972@breakpoint.cc>
References: <1448054520-1464587-1-git-send-email-tom@herbertland.com>
 <1448272388.3983270.447381049.07BA3A5C@webmail.messagingengine.com>
 <CALx6S34TrGgmH3eZKPLw_xKYfX2dm+fZq6r7ZBe2DBPudBiSzA@mail.gmail.com>
 <20151123.145433.1554000376541433305.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@herbertland.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org, kernel-team@fb.com, davewatson@fb.com,
	alexei.starovoitov@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59276 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753341AbbKXP1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 10:27:49 -0500
Content-Disposition: inline
In-Reply-To: <20151123.145433.1554000376541433305.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Mon, 23 Nov 2015 09:33:44 -0800
> 
> > The TCP PSH flag is not defined for message delineation (neither is
> > urgent pointer). We can't change that (many people have tried to add
> > message semantics to TCP protocol but have always failed miserably).
>
> Agreed.
>
> My only gripe with kcm right now is a lack of a native sendpage.

Aside from Hannes comment -- KCM seems to be tied to the TLS work, i.e.
I have the impression that KCM without ability to do TLS in the kernel
is pretty much useless for whatever use case Tom has in mind.

And that ktls thing just gives me the creeps.

For KCM itself I don't even get the use case -- its in the 'yeah, you
can do that, but... why?' category 8-/
