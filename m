From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] [NETLINK]: Fix use after free in netlink_recvmsg
Date: Thu, 03 May 2007 13:11:39 -0700 (PDT)
Message-ID: <20070503.131139.66310255.davem@davemloft.net>
References: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
	<20070503.032714.11077929.davem@davemloft.net>
	<1178195236.6891.58.camel@violet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: marcel@holtmann.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1178195236.6891.58.camel@violet>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marcel Holtmann <marcel@holtmann.org>
Date: Thu, 03 May 2007 14:27:16 +0200

> Hi Dave,
> 
> > > When the user passes in MSG_TRUNC the skb is used after getting freed.
> > > 
> > > Signed-off-by: Patrick McHardy <kaber@trash.net>
> > > Signed-off-by: David Howells <dhowells@redhat.com>
> > 
> > Ugh, good catch, applied :-)
> 
> it seems this could be easily exploited and is at least a local DoS. It
> should be a candidate for the -stable kernel.

The MSG_TRUNC change is in 2.6.22 GIT only.

You might want to check such things before making such statements. :-/

