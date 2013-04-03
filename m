From: David Miller <davem@davemloft.net>
Subject: Re: [Linux-zigbee-devel] [PATCH 1/6] mac802154: Immediately retry
 sending failed packets
Date: Tue, 02 Apr 2013 21:56:25 -0400 (EDT)
Message-ID: <20130402.215625.1555279506975246223.davem@davemloft.net>
References: <515B4D79.40805@signal11.us>
	<20130402231319.GD28141@ws>
	<515B84EB.8020006@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: werner@almesberger.net, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <515B84EB.8020006@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Tue, 02 Apr 2013 21:24:59 -0400

> I like it for a couple of reasons.
> 1. Most supported devices have only single packet output buffer, so
> blocking in the driver is the most straight-forward way to handle it.
> The alternative is to make each driver have a workqueue for xmit() (to
> lift the blocking out from atomic context). This makes each driver simpler.
> 
> 2. All of the flow control can be handled one time in the mac802154 layer.

We have a perfectly working flow control mechanism in the generic
networking queuing layer.  Please use it instead of inventing things.

If it does not meet your needs, fix it, rather than go off and do
your own thing.  That way everyone benfits, not just you.
