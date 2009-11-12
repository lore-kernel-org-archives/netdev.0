From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] decnet: convert dndev_lock to spinlock
Date: Wed, 11 Nov 2009 19:56:12 -0800 (PST)
Message-ID: <20091111.195612.117143665.davem@davemloft.net>
References: <20091110182436.GA13374@fogou.chygwyn.com>
	<20091111093927.4a08999d@nehalam>
	<20091111094036.736762da@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve@chygwyn.com, eric.dumazet@gmail.com,
	christine.caulfield@googlemail.com, hannes@hanneseder.net,
	adobriyan@gmail.com, swhiteho@redhat.com, netdev@vger.kernel.org,
	linux-decnet-users@lists.sourceforge.net
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53678
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757200AbZKLDzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:55:46 -0500
In-Reply-To: <20091111094036.736762da@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 11 Nov 2009 09:40:36 -0800

> There is no reason for this lock to be reader/writer since
> the reader only has lock held for a very brief period.
> The overhead of read_lock is more expensive than spinlock.
> 
> Compile tested only, I am not a decnet user.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
