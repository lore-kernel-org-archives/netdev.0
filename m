From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] (3/3) netem: adjust parent qlen when duplicating
Date: Wed, 04 May 2005 01:48:02 +0200
Message-ID: <42780DB2.2090201@trash.net>
References: <20050503162550.30acf31a@dxpl.pdx.osdl.net>	<42780AC1.8040409@trash.net> <20050503163025.38bb9682.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, netem@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050503163025.38bb9682.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 04 May 2005 01:35:29 +0200
> Patrick McHardy <kaber@trash.net> wrote:
>
>>This only works in a hierarchy with just one qdisc above netem, there
>>could be up to seven (check_loop_fn prevents more than that). It's also
>>not safe because it violates qdisc locking rules, when this code is
>>executed dev->queue_lock is already taken and qdisc_lookup() grabs
>>qdisc_tree_lock, but they can only be taken in the other order.
> 
> I see... I'm leaving Stephen's patch in there for now.
> 
> Perhaps we can create some kind of "propagate up" function
> that will handle all of the parents in the qdisc hierarchy
> above netem?

That's what I already suggested, it should be pretty simple to do
so. I'll send a patch once your tree appears on kernel.org.

BTW, are you pushing it regulary or just for Linus to merge?

Regards
Patrick
