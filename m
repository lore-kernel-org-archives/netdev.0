From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] typhoon: fix a race in
 typhoon_do_get_stats
Date: Wed, 25 Aug 2010 16:37:24 -0700 (PDT)
Message-ID: <20100825.163724.35022984.davem@davemloft.net>
References: <1282659493.2477.241.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59311
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751631Ab0HYXhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:37:09 -0400
In-Reply-To: <1282659493.2477.241.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Aug 2010 16:18:13 +0200

> Its important to store 'final' values in counters,
> not using them as temporary variables,
> or this might break some SNMP applications.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
