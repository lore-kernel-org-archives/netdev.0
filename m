From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCHes] pull request: WAN
Date: Tue, 22 Jul 2008 17:39:53 -0400
Message-ID: <488653A9.50001@garzik.org>
References: <m3ljzyc9e7.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47246 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753962AbYGVVj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 17:39:58 -0400
In-Reply-To: <m3ljzyc9e7.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> Hi Jeff,
> 
> Please pull from:
> git://git.kernel.org/pub/scm/linux/kernel/git/chris/linux-2.6.git hdlc
> 
> This is based on pure v2.6.26 and includes various WAN cleanups as
> well as LMC, Zilog (hostess_sv11 + sealevel = z85230) and Cosa drivers
> ported from syncppp to generic HDLC. I have no hardware for that so -
> untested.
> 
> This makes hdlc-ppp the only user of syncppp.
> 
> My plan is to replace hdlc-ppp and syncppp with the new hdlc-ppp, hope
> that's now ok with syncppp going.
> 
> The long-term plan is to also add generic PPP interface so users can
> do PPP auth, compression and what not. 2.6.30+ maybe.
> 
> I have tried to test-merge your upstream-next branch and it causes
> conflicts in drivers/net/wan/pc300_drv.c (a trivial one) and
> net/netfilter/nf_conntrack_proto_tcp.c (some pre-2.6.26 thing I
> guess).
> 
> The first commits in my tree (after v2.6.26) are already in your tree,
> you've got them by mail. It seems that git knows that.

Anything in upstream-next went upstream, and so we need to apply this on 
top of the current Linus upstream (torvalds/linux-2.6.git) at the very 
least.

Would you mind doing that, please?

Also, git pulls are great, but it would be helpful if you supply a 
git-shortlog summary of the changes, and the patch (>400k will only go 
to me, list will ignore).

	Jeff



