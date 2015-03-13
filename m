From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the vfs tree
Date: Thu, 12 Mar 2015 23:24:26 -0400 (EDT)
Message-ID: <20150312.232426.1464986797003264151.davem@davemloft.net>
References: <20150313131543.7c050492@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@ZenIV.linux.org.uk,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	hch@lst.de, ying.xue@windriver.com
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150313131543.7c050492@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 13 Mar 2015 13:15:43 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> net/socket.c between commits 005139a14660 ("fs: remove ki_nbytes") and
> e9eab93cc2dc ("fs: don't allow to complete sync iocbs through
> aio_complete") from the vfs tree and commit 1b784140474e ("net: Remove
> iocb argument from sendmsg and recvmsg") from the net-next tree.
> 
> I fixed it up (mainly using the net-next version - see below) and can
> carry the fix as necessary (no action is required).

Al, how do you want to resolve this?
