From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next 3/7] inetpeer: use generic union inet_addr
Date: Tue, 23 Jul 2013 11:38:15 +0800
Message-ID: <1374550695.24933.19.camel@cr0>
References: <1374476713-8838-1-git-send-email-amwang@redhat.com>
	 <1374476713-8838-4-git-send-email-amwang@redhat.com>
	 <1374506315.4990.14.camel@edumazet-glaptop> <1374545131.24933.4.camel@cr0>
	 <1374546371.4990.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14721 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253Ab3GWDiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 23:38:25 -0400
In-Reply-To: <1374546371.4990.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 19:26 -0700, Eric Dumazet wrote:
> You are sending a patch with possible performance impact, and you only
> says "its safe", without any real study. It might have an impact, who
> knows.
> 
> I said "its no big deal", so consider this as an informative message. 

Yeah.

So changing from struct inetpeer_addr to union inet_addr just adds few
bytes (8 bytes if I don't make mistake) to struct tcp_metrics_block,
therefore should not cause performance issue on 32bit and 64bit?

BTW, I tried to use pahole to get the offsets of these fields, but it
doesn't work for me.

Thanks!
