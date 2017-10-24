From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net/sock: Update sk rcu iterator macro.
Date: Tue, 24 Oct 2017 18:46:59 +0900 (KST)
Message-ID: <20171024.184659.760728760499677647.davem@davemloft.net>
References: <20171023193558.fhjoxerpzq6pqbo7@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexander.levin@one.verizon.com
To: devtimhansen@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171023193558.fhjoxerpzq6pqbo7@debian>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Hansen <devtimhansen@gmail.com>
Date: Mon, 23 Oct 2017 15:35:58 -0400

> Mark hlist node in sk rcu iterator as protected by the rcu.
> hlist_next_rcu accomplishes this and silences the warnings
> sparse throws.
> 
> Found with make C=1 net/ipv4/udp.o on linux-next tag 
> next-20171009.
> 
> Signed-off-by: Tim Hansen <devtimhansen@gmail.com>

Applied.
