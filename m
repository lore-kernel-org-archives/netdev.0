From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: don't apply tsoffset if rcv_tsecr is zero
Date: Thu, 29 Aug 2013 15:12:13 -0400 (EDT)
Message-ID: <20130829.151213.1901946252095108600.davem@davemloft.net>
References: <1377591715-1742-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gorcunov@openvz.org,
	linux-kernel@vger.kernel.org, xemul@parallels.com,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377591715-1742-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Vagin <avagin@openvz.org>
Date: Tue, 27 Aug 2013 12:21:55 +0400

> From: Andrew Vagin <avagin@openvz.org>
> 
> The zero value means that tsecr is not valid, so it's a special case.
> 
> tsoffset is used to customize tcp_time_stamp for one socket.
> tsoffset is usually zero, it's used when a socket was moved from one
> host to another host.
> 
> Currently this issue affects logic of tcp_rcv_rtt_measure_ts. Due to
> incorrect value of rcv_tsecr, tcp_rcv_rtt_measure_ts sets rto to
> TCP_RTO_MAX.
> 
> Reported-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied and queued up for -stable.
