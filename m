From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.24 plans
Date: Mon, 17 Sep 2007 14:18:26 -0700 (PDT)
Message-ID: <20070917.141826.70218261.davem@davemloft.net>
References: <20070916.202258.03371690.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linville@tuxdriver.com,
	jgarzik@pobox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41277
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932910AbXIQVS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2007 17:18:28 -0400
In-Reply-To: <20070916.202258.03371690.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 16 Sep 2007 20:22:58 -0700 (PDT)

> Tomorrow (Monday) I want to rebase the net-2.6.24 tree one more time
> to deal with all of the conflicts which exist between
> linux-2.6/net-2.6 and net-2.6.24, but I'll likely defer that
> until the net-2.6 fixes I just pushed to Linus are integrated.

I've just completed this rebase.

Andrew, I removed the troublesome IOAT patch.  The only conflicts
and fixes you should need at this point are:

1) Removal of SET_MODULE_OWNER() from any extra drivers you import
   into your tree.

2) dev_get_by_*() needs &init_net added as first parameter in any
   other code you import outside of the net tree.

I guess a lot of this could be avoided if I simply merge in whatever
external stuff you're sucking in.  I imagine this is just one of
Linville's trees (I'm surprised that hasn't been sent to me frankly)
and some specific new drivers you're merging in.

I don't want to sound like a control freak or a whiner, but these
merge conflicts are growing painful at an astronomic rate and I'd
therefore prefer if we simply push everything through the net-2.6.24
tree from now until the merge window.

Today's rebase took several hours and it took significantly longer to
suck in Jeff's netdev tree over the weekend.  I'm tired of playing
patch monkey, so I can sympathize with how life must be every day
for Andrew :-)  But on a more serious note there are things I have
to actually hack on myself so anything that decreases the amount of
time I spend doing mindless patch whacking in the net-2.6.24 tree is
appreciated.

What say you?
