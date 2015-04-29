From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] tcp: prepare CC get_info() access from
 getsockopt()
Date: Wed, 29 Apr 2015 15:40:39 -0700
Message-ID: <1430347239.3711.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1430263429-4069-1-git-send-email-edumazet@google.com>
	 <1430263429-4069-2-git-send-email-edumazet@google.com>
	 <20150429.181252.2106091176943411796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ycheng@google.com,
	ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:38229 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbbD2Wkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 18:40:41 -0400
Received: by igbhj9 with SMTP id hj9so62785309igb.1
        for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:40:40 -0700 (PDT)
In-Reply-To: <20150429.181252.2106091176943411796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-29 at 18:12 -0400, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Tue, 28 Apr 2015 16:23:48 -0700
> 
> > We would like that optional info provided by Congestion Control
> > modules using netlink can also be read using getsockopt()
> > 
> > This patch changes get_info() to put this information in a buffer,
> > instead of skb, like tcp_get_info(), so that following patch
> > can reuse this common infrastructure.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied.

Thanks David, I'll send an update to tcp_westwood, kbuild test robot
gave me a notice.
