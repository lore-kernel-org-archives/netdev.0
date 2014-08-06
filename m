From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: [PATCH net-next v2] tcp: md5: check md5 signature without
 socket lock
Date: Thu, 7 Aug 2014 02:33:47 +0400
Message-ID: <20140807023347.ad7215e4c192672ef23ee3ac@qrator.net>
References: <20140807014953.d8c4cde302bb9b30f8efe0e1@qrator.net>
	<20140806.145218.1742159418901363810.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140806.145218.1742159418901363810.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 06 Aug 2014 14:52:18 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Dmitry Popov <ixaphire@qrator.net>
> Date: Thu, 7 Aug 2014 01:49:53 +0400
> 
> > Since a8afca032 (tcp: md5: protects md5sig_info with RCU) tcp_md5_do_lookup
> > doesn't require socket lock, rcu_read_lock is enough. Therefore socket lock is
> > no longer required for tcp_v{4,6}_inbound_md5_hash too, so we can move these
> > calls (wrapped with rcu_read_{,un}lock) before bh_lock_sock:
> > from tcp_v{4,6}_do_rcv to tcp_v{4,6}_rcv.
> > 
> > Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
> 
> Please respin this against the current 'net' tree, it doesn't apply.

Oops, my bad, sorry. I will resubmit.
