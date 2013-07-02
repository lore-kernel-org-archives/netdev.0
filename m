From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: 3.6 NULL kernel dereference in skb_gro_receive()
Date: Tue, 02 Jul 2013 13:51:33 -0400
Message-ID: <1372787493.22688.50.camel@gandalf.local.home>
References: <1372782217.22688.48.camel@gandalf.local.home>
	 <1372783137.4979.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>,
	"Luis Claudio R. Goncalves" <lgoncalv@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372783137.4979.10.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-07-02 at 09:38 -0700, Eric Dumazet wrote:

> Could you check if your kernel has commit 2e71a6f8084e ("net: gro:

Yeah, I saw this in the git logs, and no our tree doesn't have that
commit.

> selective flush of packets"), and the fix contained in commit
> c3c7c254b2e8cd99b0adf288c2a1bddacd7ba255
> ("net: gro: fix possible panic in skb_gro_receive() ")
> 
> Normally, first commit was in 3.7-rc1, but maybe it was backported into
> you 3.6.11 kernel ?
> 
> Do you have a git tree for your kernel ?

I'm not sure if the Red Hat kernel has a public git tree, but it's
almost identical to my 3.6-rt tree:

git://git.kernel.org/pub/scm/linux/kernel/git/rt/linux-stable-rt.git

branch: v3.6-rt

-- Steve
