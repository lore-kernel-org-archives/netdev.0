From: David Miller <davem@davemloft.net>
Subject: Re: Commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 has broken ss
 command
Date: Wed, 04 Apr 2012 05:24:23 -0400 (EDT)
Message-ID: <20120404.052423.998527504342669775.davem@davemloft.net>
References: <20120404090312.1B68C6AC03E@msa102.auone-net.jp>
	<1333530463.18626.545.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: slash@ac.auone-net.jp, netdev@vger.kernel.org, xemul@parallels.com,
	linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333530463.18626.545.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Apr 2012 11:07:43 +0200

> On Wed, 2012-04-04 at 18:03 +0900, Kusanagi Kouichi wrote:
>> Since commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 ("sock_diag:
>> Move the sock_ code to net/core/"), ss command from iproute package
>> doesn't work if INET_DIAG is not enabled.
>> 
>> $ ss
>> State       Recv-Q Send-Q                                             Local Address:Port                                                 Peer Address:Port
>> TCPDIAG answers: Operation not supported
>> --
> 
> Try to update your iproute2 package ?

Well, he doesn't INET_DIAG enabled in his kernel, so no matter what
iproute2 version he uses it won't work :-)
