From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 has broken ss
 command
Date: Wed, 04 Apr 2012 11:07:43 +0200
Message-ID: <1333530463.18626.545.camel@edumazet-glaptop>
References: <20120404090312.1B68C6AC03E@msa102.auone-net.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>,
	linux-kernel@vger.kernel.org
To: Kusanagi Kouichi <slash@ac.auone-net.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404090312.1B68C6AC03E@msa102.auone-net.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-04-04 at 18:03 +0900, Kusanagi Kouichi wrote:
> Since commit 8ef874bfc7296fa206eea2ad1e8a426f576bf6f6 ("sock_diag:
> Move the sock_ code to net/core/"), ss command from iproute package
> doesn't work if INET_DIAG is not enabled.
> 
> $ ss
> State       Recv-Q Send-Q                                             Local Address:Port                                                 Peer Address:Port
> TCPDIAG answers: Operation not supported
> --

Try to update your iproute2 package ?
