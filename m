From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: add setsockopt to disable slow start after idle
Date: Sat, 10 Apr 2010 15:47:09 -0700 (PDT)
Message-ID: <20100410.154709.201110995.davem@davemloft.net>
References: <1270863015-19597-1-git-send-email-cristiklein@gmail.com>
	<20100409.221307.246951787.davem@davemloft.net>
	<4BC06A5F.6070804@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cristiklein@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52959
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752063Ab0DJWrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Apr 2010 18:47:08 -0400
In-Reply-To: <4BC06A5F.6070804@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cristian KLEIN <cristiklein@gmail.com>
Date: Sat, 10 Apr 2010 14:09:03 +0200

> Could you please explain me why it is dangerous? To me it seems that
> it's just like allowing applications to disable NAGLE or to choose a
> congestion control algorithm.

Because you can cause undue congestion to other people on the network
because you are believing path information that has been outdated and
has not been validated by sending data for a certain amount of time.
