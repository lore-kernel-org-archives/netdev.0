From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, v2] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 19 May 2009 14:24:12 -0700 (PDT)
Message-ID: <20090519.142412.05111919.davem@davemloft.net>
References: <20090518.221956.153457626.davem@davemloft.net>
	<4A130C0E.6000507@cosmosbay.com>
	<20090519210937.GA4850@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org, kaber@trash.net
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43501
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751138AbZESVYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:24:14 -0400
In-Reply-To: <20090519210937.GA4850@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Tue, 19 May 2009 23:09:37 +0200

> Hmm... Of course, this patch looks OK to me, but actually my main
> concern was more general. We avoid adding such flags for each "real"
> dev, but if so IMHO it would be safer to generally add them to all
> "virtual" devs - needed or not. You prefer to do this only where
> necessary, but it's not always clear if it's omitted on purpose or
> by chance. So, now I'm wondering about xen-netfront - needlessly I
> hope ;-)

It is an issue that surely needs to be fleshed out, to make
sure we use this where possible without breaking odd cases
too easily.

But for now I'm applying Eric's patch because it does fix
something until we have these issues sorted more generally.
