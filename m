From: David Miller <davem@davemloft.net>
Subject: Re: net: add seq_before/seq_after functions
Date: Thu, 19 May 2011 14:52:26 -0400 (EDT)
Message-ID: <20110519.145226.81502363776050802.davem@davemloft.net>
References: <201105191054.34912.sven@narfation.org>
	<20110519.050824.838971689287732822.davem@davemloft.net>
	<201105191121.23888.sven@narfation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ordex@autistici.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: sven@narfation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201105191121.23888.sven@narfation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sven Eckelmann <sven@narfation.org>
Date: Thu, 19 May 2011 11:21:21 +0200

> This is currently used by vis.c in net/batman-adv and could also be used by 
> ppp-generic.c (with my changes of course). And it is planned to be used by 
> transtable.c in net/batman-adv. The idea was to propose this to linux-
> kernel/netdev before we move it to a place were only batman-adv can use it 
> (the current situation is that vis.c in batman-adv can only use it).
> 
> It is ok that you say that it should be batman-adv specific - we only wanted 
> to ask first.

Well, this is a purely networking change, the header you're touching is
networking specific, so really in this case linux-kernel didn't need to
get involved :-)
