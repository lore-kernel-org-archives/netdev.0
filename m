From: Kusanagi Kouichi <slash@ac.auone-net.jp>
Subject: Re: Commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 has broken ss
 command
Date: Wed, 4 Apr 2012 19:00:15 +0900
Message-ID: <20120404100015.D41B162C03E@msa106.auone-net.jp>
References: <20120404090312.1B68C6AC03E@msa102.auone-net.jp>
 <1333530463.18626.545.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1333530463.18626.545.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2012-04-04 11:07:43 +0200, Eric Dumazet wrote:
> On Wed, 2012-04-04 at 18:03 +0900, Kusanagi Kouichi wrote:
> > Since commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 ("sock_diag:
> > Move the sock_ code to net/core/"), ss command from iproute package
> > doesn't work if INET_DIAG is not enabled.
> > 
> > $ ss
> > State       Recv-Q Send-Q                                             Local Address:Port                                                 Peer Address:Port
> > TCPDIAG answers: Operation not supported
> > --
> 
> Try to update your iproute2 package ?

iproute seems up to date.
$ ss --version
ss utility, iproute2-ss120319

I tried git master commit 4bb00cd2b7525ad7d6cf6bbea945ad6e546873f4.
It still fails.
