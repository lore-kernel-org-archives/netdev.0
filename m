From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next 09/14] igb: Report L4 Rx hash via skb->l4_rxhash
Date: Thu, 17 Jan 2013 09:14:49 -0800
Message-ID: <1358442889.29723.58.camel@edumazet-glaptop>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1358422519-20981-10-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1358432385.29723.6.camel@edumazet-glaptop>  <50F82FCA.9090709@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:56505 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446Ab3AQROx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 12:14:53 -0500
Received: by mail-pb0-f54.google.com with SMTP id wz12so1520641pbc.27
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 09:14:53 -0800 (PST)
In-Reply-To: <50F82FCA.9090709@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-17 at 09:07 -0800, Alexander Duyck wrote:

> Isn't the same true of TCP?  I believe STT is intended to run over the
> TCP protocol, or am I getting ahead of myself since STT is not supported
> by the kernel?
> 

probably ;)

> > Also, is IGB really using the ports in the rss for UDP packets ?
> 
> Not by default.  The default is to only hash on the IP header for UDP
> packets.
> 
> As such the default would only be setting the l4_rxhash on TCP frames
> only.  The user would have to specifically request L4 port hashing for
> UDP via the "ethtool -N" command for configuring rx-flow-hash.

So you should rewrite this patch ?

Or have I missed something ?
