From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] decnet: add RTNL lock when reading address list
Date: Wed, 11 Nov 2009 19:56:01 -0800 (PST)
Message-ID: <20091111.195601.70642848.davem@davemloft.net>
References: <20091110105053.16687e93@nehalam>
	<20091110182436.GA13374@fogou.chygwyn.com>
	<20091111093927.4a08999d@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve@chygwyn.com, eric.dumazet@gmail.com,
	christine.caulfield@googlemail.com, hannes@hanneseder.net,
	adobriyan@gmail.com, swhiteho@redhat.com, netdev@vger.kernel.org,
	linux-decnet-users@lists.sourceforge.net
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53670
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755843AbZKLDze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 22:55:34 -0500
In-Reply-To: <20091111093927.4a08999d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 11 Nov 2009 09:39:27 -0800

> Add missing locking in the case of auto binding to the
> default device. The address list might change while this code is looking
> at the list. 
> 
> Compile tested only, I am not a decnet user.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-next-2.6
