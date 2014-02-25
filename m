From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next v2 2/6] 6lowpan: fix fragmentation on sending
 side
Date: Tue, 25 Feb 2014 03:38:34 +0100
Message-ID: <20140225023833.GA18062@omega>
References: <1393009142-1694-3-git-send-email-alex.aring@gmail.com>
 <20140224.185213.1069306984692624378.davem@davemloft.net>
 <20140225012155.GA16712@omega>
 <20140224.203138.676703794377468037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:64766 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaBYCil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 21:38:41 -0500
Received: by mail-ee0-f43.google.com with SMTP id e51so3446198eek.2
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 18:38:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140224.203138.676703794377468037.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 24, 2014 at 08:31:38PM -0500, David Miller wrote:
> From: Alexander Aring <alex.aring@gmail.com>
> Date: Tue, 25 Feb 2014 02:21:57 +0100
> 
> > In this case I can be sure we talking with ARPHRD_IEEE802154 devices only.
> 
> This doesn't mean anything.
> 
> The qdisc layer can be involved no matter what.  Once you call
> dev_queue_xmit(), all bets are off wrt. the SKB control block.
> It is not your's to use past that point.
> 
Okay, thanks. Then I know some other issues we have right now. I will
put it on my todo list and will make a other non cb solution for this
part.

- Alex
