From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: tc related lockdep warning.
Date: Thu, 28 Sep 2006 11:07:28 +0200
Message-ID: <20060928090728.GB1820@ff.dom.local>
References: <45195219.7050105@trash.net> <20060926212034.GA3134@redhat.com> <451A6968.2090607@trash.net> <20060927.165304.116354998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davej@redhat.com, hadi@cyberus.ca,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:27810 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S1751772AbWI1JDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 05:03:08 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060927.165304.116354998.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 27, 2006 at 04:53:04PM -0700, David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 27 Sep 2006 14:07:04 +0200
...
> Although the HTB bug is post-2.6.18, the other issue has been
> around for a long time.
> 
> Thus I'll need to submit the second patch to -stable, but I want
> it to cook in Linus's tree for a few days before I do that.

I don't know which version of act_police.c is planned for
2.6.18 -stable but I think it would be nice to fix the
original bug of this thread in 2.6.17 etc.
So I remind the proposal of read_lock_bh in tcf_police_lookup. 

Jarek P.
