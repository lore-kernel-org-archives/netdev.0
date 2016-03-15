From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next] rds-tcp: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Tue, 15 Mar 2016 13:30:11 -0400
Message-ID: <20160315173011.GM11063@oracle.com>
References: <20160315151248.GJ11063@oracle.com>
 <56E83A6D.6060904@oracle.com>
 <20160315165800.GL11063@oracle.com>
 <1458062294.31401.37.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh shilimkar <santosh.shilimkar@oracle.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24768 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965418AbcCORaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 13:30:20 -0400
Content-Disposition: inline
In-Reply-To: <1458062294.31401.37.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/15/16 10:18), Eric Dumazet wrote:
> 
> Look at SO_SNDBUF and SO_RCVBUF implementation.
> 
> sk->sk_sndbuf = max_t(u32, val * 2, SOCK_MIN_SNDBUF);
> 
> sk->sk_rcvbuf = max_t(u32, val * 2, SOCK_MIN_RCVBUF);
> 
> kernel definitely has some logic here.

Ok, I can do the same thing (and we do this consistently across
all drivers?)

> If you believe SOCK_MIN_SNDBUF and/or SOCK_MIN_RCVBUF are wrong, please
> elaborate.

I dont recall suggesting that. 

BTW, when I tried it, doing a SO_SNDBUF of 1 from uspace does not return
an error. It merely sets the buffer size to 4608 (as reported by
getsockopt in my env. I think the getsockopt value is impacted by
many factors).

--Sowmini
