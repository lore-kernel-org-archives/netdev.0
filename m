From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [RFC] Multiple IPV6 Routing Tables & Policy Routing
Date: Mon, 31 Jul 2006 14:01:11 +0300
Message-ID: <44CDE2F7.3010302@tcs.hut.fi>
References: <20060726221100.325687073@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net, anttit@tcs.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:42249 "EHLO neon.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S932179AbWGaLBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 07:01:12 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060726221100.325687073@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Hello,

Hi Thomas!

> Thought it might be time to go through a round of comments
> on this work. Even though I've almost rewritten all the code
> the patches are based on the work found on www.mobile-ipv6.org.
> I have no idea which code was written by whom so just email me
> to get the credits right.

The policy routing stuff (multiple tables and source address based
routing) was almost entirely written by me. Therefore you can apply my
name as you see fit ;-)

Tushar Gohad at MontaVista, Benjamin Thery at Bull and of course USAGI
have also worked on the code.

> Main differences to the version found on mobile-ipv6.org is
> that I removed table refcnt and defined that tables cannot
> disappear once created to simplify things and avoid too many
> atomic operations when looking up routes.

Yes, that sounds good. As the ipv6 module doesn't really seem to become
unloadable anytime soon, there isn't really any good reason to refcount
the tables.

> I've replaced the
> table array with a hash table to prepare it for > 255 tables
> and made things aware of the new default router selection
> code and experimental route info stuff added recently.

Good! I never had the time to merge our changes with 2.6.17.

> It's not final but somewhat working, I'm eager to see comments
> or patches.

I'll try to comment on them the best I can.

> I apologize if I've tramped onto anybody's foot
> by taking this up and submitting it, this isn't meant as an
> attempt to steal credits but rather to pick up good code and
> finally get it upstream after a very long while.

No offense taken! It's great that someone wants to push these things
upstream as I personally have neither had the time nor the energy to do
so lately.

Regards,
Ville
