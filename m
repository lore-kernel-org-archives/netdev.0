From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH?] Fix call to ->change_rx_flags(dev, IFF_MULTICAST) in
 dev_change_flags()
Date: Tue, 20 May 2008 14:47:32 +0200
Message-ID: <4832C864.8020605@trash.net>
References: <1211285486.21380.204.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38513 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754335AbYETMri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 08:47:38 -0400
In-Reply-To: <1211285486.21380.204.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> Am I just being particularly dim today, or can the call to
> dev->change_rx_flags(dev, IFF_MULTICAST) in dev_change_flags() never
> happen?
> 
> We've just set dev->flags = flags & IFF_MULTICAST, effectively. So the
> condition '(dev->flags ^ flags) & IFF_MULTICAST' is _never_ going to be
> true.

Thanks for catching this, you're correct of course.
