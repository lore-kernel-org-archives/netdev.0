From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 10 Mar 2011 15:55:56 -0800 (PST)
Message-ID: <20110310.155556.48513201.davem@davemloft.net>
References: <20110310.153444.115930379.davem@davemloft.net>
	<AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Mar 2011 15:49:40 -0800

> Grr. This has been going on for too long. Don't do it. Don't do random
> backwards merges without explanations, and with the actual source data
> removed.
> 
> We're _really_ good at doing commit messages, and the kernel commit
> log should be a great example to other projects. But in the last week
> or so, I've now _twice_ had to flame core developers for making
> totally useless commit messages.
> 
> So don't do back-merges. And if you DO do back-merges, don't make the
> commit message totally useless.
> 
> You can use either 'git commit --amend" to fix the message afterwards
> and explain WHY you did the stupid thing, or you can just do "git pull
> --no-commit" to not actually commit the merge and then write your
> commit message as you do it. But preferably you shouldn't do the
> back-merges at all.

I'm sorry about this, won't happen again.

I should have put:

	Merge to get commit 8909c9ad8ff03611c9c96c9a92656213e4bb495b
	("net: don't allow CAP_NET_ADMIN to load non-netdev kernel modules")
	so that we can add Stephen Hemminger's fix to handle ip6 tunnels
	as well, which uses the MODULE_ALIAS_NETDEV() macro created by
	that change.

Again, sorry.
