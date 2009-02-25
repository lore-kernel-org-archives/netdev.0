From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-next-2.6 2009-02-23
Date: Tue, 24 Feb 2009 23:55:10 -0800 (PST)
Message-ID: <20090224.235510.30497146.davem@davemloft.net>
References: <20090223192659.GB3553@tuxdriver.com>
	<1235457113.4455.89.camel@johannes.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54874
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758097AbZBYHz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 02:55:29 -0500
In-Reply-To: <1235457113.4455.89.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 23 Feb 2009 22:31:53 -0800

> On Mon, 2009-02-23 at 14:26 -0500, John W. Linville wrote:
> 
> > Johannes Berg (10):
> >       mac80211: disallow moving netns
> >       mac80211: fix aggregation for hardware with ampdu queues
> >       mac80211: split IBSS/managed code
> >       genetlink: introduce pre/post methods
> 
> Hold off on this please, the genetlink patch here introduced a problem
> with locking and I'm going to rework/fix that.

Ok.

In fact it's better this way, since now John can send me the pull
request after the net-2.6 --> net-next-2.6 merge conflicts are
resolved.
