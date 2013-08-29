From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: initialize rcv_tstamp for restored sockets
Date: Thu, 29 Aug 2013 15:12:05 -0400 (EDT)
Message-ID: <20130829.151205.2070859347984247313.davem@davemloft.net>
References: <1377591640-1660-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gorcunov@openvz.org,
	linux-kernel@vger.kernel.org, xemul@parallels.com,
	eric.dumazet@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377591640-1660-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Vagin <avagin@openvz.org>
Date: Tue, 27 Aug 2013 12:20:40 +0400

> From: Andrew Vagin <avagin@openvz.org>
> 
> u32 rcv_tstamp;     /* timestamp of last received ACK */
> 
> Its value used in tcp_retransmit_timer, which closes socket
> if the last ack was received more then TCP_RTO_MAX ago.
> 
> Currently rcv_tstamp is initialized to zero and if tcp_retransmit_timer
> is called before receiving a first ack, the connection is closed.
> 
> This patch initializes rcv_tstamp to a timestamp, when a socket was
> restored.
> 
> Reported-by: Cyrill Gorcunov <gorcunov@openvz.org>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied and queued up for -stable.
