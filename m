From: David Miller <davem@davemloft.net>
Subject: [PATCH v6 0/3] rtcache removal respin
Date: Thu, 05 May 2011 16:35:59 -0700 (PDT)
Message-ID: <20110505.163559.15226272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, jpirko@redhat.com, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47489
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753919Ab1EEXgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 19:36:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As before, this is just a respin of the routing cache removal patches
for people who want to play with this stuff.

The patch set has shrunk significantly, because several changes in the
previous series have been integrated to net-next-2.6

One new change is that now rt->rt_key_tos is removed alongside
rt->rt_key_{dst,src}

And finally, I've included an extra bonus patch showing an
experimental scheme I'm working on which will make output route
resolution in a routing-cache-less environment extremely fast.

Enjoy.
