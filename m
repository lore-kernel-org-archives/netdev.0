From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH (take 2)] netdev: lockdep classes in register_netdevice Re: [patch 04/13] ppp_generic: fix lockdep warning
Date: Wed, 16 May 2007 08:17:32 +0200
Message-ID: <20070516061732.GB1801@ff.dom.local>
References: <20070514060700.GA1000@ff.dom.local> <20070513.233937.99203647.davem@davemloft.net> <20070516054000.GB967@ff.dom.local> <20070515.224725.95062491.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, jeff@garzik.org, netdev@vger.kernel.org,
	jura@netams.com, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:46608 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754435AbXEPGK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 02:10:57 -0400
Content-Disposition: inline
In-Reply-To: <20070515.224725.95062491.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 15, 2007 at 10:47:25PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@o2.pl>
> Date: Wed, 16 May 2007 07:40:00 +0200
> 
> > After initializing dev->_xmit_lock register_netdevice()
> > sets lockdep class according to dev->type.
> > 
> > Idea of this patch - by David Miller.
> > 
> > Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
> > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> 
> Patch applied, dziekuje bardzo.
> 

I cannot believe this! I'm even more surprised then, when
I heard it from Borat. So, you know the ... Kazakh too!)

BTW - I think some patch on vlan cannot do any harm (at
least like this previous of mine - with only ppp
considered), and maybe this all could be forgotten.

Pozdrawiam,
Jarek P.
