From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.22 1/3] [TCP]: Sed magic converts func(sk, tp,
 ...) -> func(sk, ...)
Date: Mon, 16 Apr 2007 17:16:04 -0700 (PDT)
Message-ID: <20070416.171604.26532491.davem@davemloft.net>
References: <Pine.LNX.4.64.0704161758020.28337@kivilampi-30.cs.helsinki.fi>
	<462396F5.9030907@trash.net>
	<Pine.LNX.4.64.0704161913400.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kaber@trash.net, hch@infradead.org, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53954
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754091AbXDQAQC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 20:16:02 -0400
In-Reply-To: <Pine.LNX.4.64.0704161913400.28337@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Mon, 16 Apr 2007 19:19:02 +0300 (EEST)

> [PATCH] [TCP]: Sed magic converts func(sk, tp, ...) -> func(sk, ...)

I was trying to spread out the net-2.6.22 tree from the tcp-2.6
one so that we could do the experimental TCP stuff in the tcp-2.6
tree and leave other networking changes for net-2.6.22

Putting in TCP cleanups which touch a lot of code into net-2.6.22
defeats that effort because now there will be all kinds of rejects and
merge errors people will have to deal with if they clone a net-2.6.22
tree then pull in tcp-2.6 to do some TCP hacking which is valid.

I suppose we can live with that, and just tell people to just pull
tcp-2.6 into a fresh linux-2.6 tree straight, but it's going to make
rebasing difficult for me as well.

net-2.6.22 is already approaching 350 patches, it's a monster and
the merge conflicts and rebasing pain are really getting hard to
deal with.

=46or example, John Linville probably now has some build failures
to deal with in his wireless-2.6 tree due to Patrick McHardy's
netlink_kernel_create() function signature change today.

Also, the VLAN skb->h.raw bug fix from the other day in mainline
vanilla 2.6 tree is going to cause a build failure I'll have to
fixup next time I rebase, and people will hit that now if they
try to use current linux-2.6.git to pull in the net-2.6.22 tree.
