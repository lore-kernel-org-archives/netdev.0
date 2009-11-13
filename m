From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH] net: fast consecutive name allocation
Date: Fri, 13 Nov 2009 14:29:39 -0800
Message-ID: <20091113142939.35879efe@s6510>
References: <200911130701.14847.opurdila@ixiacom.com>
	<4AFCF8D3.6090905@gmail.com>
	<20091112222608.79d90e9e@nehalam>
	<200911131151.31677.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54834 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756542AbZKMW36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 17:29:58 -0500
In-Reply-To: <200911131151.31677.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2009 11:51:31 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> For us the usecase is creating interfaces that get used by applications that 
> generate all sorts of traffic. This allows us to simulate realistic end user 
> traffic (e.g. coming from a full blown stack). That sounds reasonable to us :)

So it is lots of pseudo-devices for a special purpose test machine.
That's great use of Linux, but not a case worth optimizing for in the mainline kernel.
