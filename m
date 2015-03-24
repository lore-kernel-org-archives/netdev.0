From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: validate length of sockaddr in connect() for
 dgram/rdm
Date: Tue, 24 Mar 2015 12:57:31 -0400 (EDT)
Message-ID: <20150324.125731.1973092060458690117.davem@davemloft.net>
References: <1427139003-30510-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, erik.hugne@ericsson.com,
	ying.xue@windriver.com, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: sasha.levin@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427139003-30510-1-git-send-email-sasha.levin@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sasha Levin <sasha.levin@oracle.com>
Date: Mon, 23 Mar 2015 15:30:00 -0400

> Commit f2f8036 ("tipc: add support for connect() on dgram/rdm sockets")
> hasn't validated user input length for the sockaddr structure which allows
> a user to overwrite kernel memory with arbitrary input.
> 
> Fixes: f2f8036 ("tipc: add support for connect() on dgram/rdm sockets")
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>

Applied, thanks.
