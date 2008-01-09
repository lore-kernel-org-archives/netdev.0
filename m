From: Andi Kleen <andi@firstfloor.org>
Subject: Re: SACK scoreboard
Date: Wed, 9 Jan 2008 15:02:48 +0100
Message-ID: <20080109140248.GA12855@one.firstfloor.org>
References: <4783AA29.3080406@psc.edu> <20080108.144456.173014334.davem@davemloft.net> <p73sl17pwfy.fsf@bingen.suse.de> <20080108.223925.105105455.davem@davemloft.net> <20080109070318.GA8581@one.firstfloor.org> <20080109094725.GA22140@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, jheffner@psc.edu,
	ilpo.jarvinen@helsinki.fi, lachlan.andrew@gmail.com,
	netdev@vger.kernel.org, quetchen@caltech.edu
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:47550 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbYAIOAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 09:00:18 -0500
Content-Disposition: inline
In-Reply-To: <20080109094725.GA22140@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Postponing freeing of the skb has major drawbacks. Some time ago I

Yes, the trick would be to make sure that it also does not tie up
too much memory. e.g. it would need some throttling at least.

Also the fast path of kmem_cache_free() is actually not that
much different from just putting something on a list so perhaps
it would not make that much difference.

-Andi
