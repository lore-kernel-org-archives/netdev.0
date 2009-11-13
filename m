From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 17:40:43 -0500
Message-ID: <20091113224043.GP19478@kvack.org>
References: <200911130701.14847.opurdila@ixiacom.com> <4AFCF8D3.6090905@gmail.com> <20091112222608.79d90e9e@nehalam> <200911131151.31677.opurdila@ixiacom.com> <20091113142939.35879efe@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:47040 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932128AbZKMWkj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 17:40:39 -0500
Content-Disposition: inline
In-Reply-To: <20091113142939.35879efe@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 13, 2009 at 02:29:39PM -0800, Stephen Hemminger wrote:
> So it is lots of pseudo-devices for a special purpose test machine.
> That's great use of Linux, but not a case worth optimizing for in the mainline kernel.

He's not the only one who needs that, I certainly do.  BRAS application 
where traffic is being aggregated (ie PPPoE and L2TP servers) from lots of 
customers requires it.  There are also people hitting the same scaling 
issues in embedded PPPoE on wireless networks.

		-ben
