From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: experimental zero copy tx support
Date: Mon, 14 May 2012 22:31:35 +0300
Message-ID: <20120514193134.GA18366@redhat.com>
References: <20120513155206.GA26847@redhat.com>
 <20120514095446.3ce307d2@nehalam.linuxnetplumber.net>
 <20120514170412.GA17086@redhat.com>
 <1337022146.8512.606.camel@edumazet-glaptop>
 <20120514191456.GC17086@redhat.com>
 <1337023307.8512.617.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ian.Campbell@citrix.com,
	kvm@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757613Ab2ENTbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 15:31:40 -0400
Content-Disposition: inline
In-Reply-To: <1337023307.8512.617.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 14, 2012 at 09:21:47PM +0200, Eric Dumazet wrote:
> On Mon, 2012-05-14 at 22:14 +0300, Michael S. Tsirkin wrote:
> 
> > They seem to be in net-next, or did I miss something?
> 
> Yes, you re-introduce in this patch some bugs already fixed in macvtap

Could explain why I see some problems in testing :)
Maybe common code should go into net/core?
I couldn't decide whether the increase in kernel
size is worth it.

-- 
MST
