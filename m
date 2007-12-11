From: David Miller <davem@davemloft.net>
Subject: Re: net-2.6.25 being rebased...
Date: Tue, 11 Dec 2007 13:08:58 -0800 (PST)
Message-ID: <20071211.130858.134618588.davem@davemloft.net>
References: <20071211.092638.148402625.davem@davemloft.net>
	<20071211.115619.199600421.davem@davemloft.net>
	<1197407100.4911.150.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750772AbXLKVJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 16:09:00 -0500
In-Reply-To: <1197407100.4911.150.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Tue, 11 Dec 2007 13:04:59 -0800

> On Tue, 2007-12-11 at 11:56 -0800, David Miller wrote:
> > The rebase of net-2.6.25 is complete
> 
> I have an earlier unmodified git repository of net-2.6.25.
> Does anyone know the appropriate git commands to resync
> to the rebased content?
> 
> $ git branch
> * master
> $ git-pull
> [...]
> Automatic merge failed; fix conflicts and then commit the result.

Easiest thing to do is do a quick local clone of Linus's current tree
(you do have one of these around right? :-) and then pull in from the
rebased tree.

bash$ git clone linux-2.6/.git net-2.6.25
bash$ git pull git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git
