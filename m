From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: correctly handle releasing a not fully
 initialized sock
Date: Tue, 13 Jan 2015 17:25:23 -0500 (EST)
Message-ID: <20150113.172523.1612644763021758959.davem@davemloft.net>
References: <1421171201-25224-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ying.xue@windriver.com,
	Tero.Aho@coriant.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421171201-25224-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Tue, 13 Jan 2015 12:46:41 -0500

> Commit "tipc: make tipc node table aware of net namespace" has added a
> dereference of sock->sk before making sure it's not NULL, which makes
> releasing a tipc socket NULL pointer dereference for sockets that are
> not fully initialized.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Good catch, applied, thanks.
