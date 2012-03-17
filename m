From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netfilter: ctnetlink: fix race between delete and
 timeout expiration
Date: Sat, 17 Mar 2012 01:47:39 -0700 (PDT)
Message-ID: <20120317.014739.1582874215726456340.davem@davemloft.net>
References: <1331899234-3123-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331899234-3123-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Fri, 16 Mar 2012 13:00:34 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Kerin Millar reported hardlockups while running `conntrackd -c'
> in a busy firewall. That system (with several processors) was
> acting as backup in a primary-backup setup.
> 
> After several tries, I found a race condition between the deletion
> operation of ctnetlink and timeout expiration. This patch fixes
> this problem.
> 
> Tested-by: Kerin Millar <kerframil@gmail.com>
> Reported-by: Kerin Millar <kerframil@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied, thanks.
