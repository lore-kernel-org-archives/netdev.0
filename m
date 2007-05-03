From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] [NETLINK]: Fix use after free in netlink_recvmsg
Date: Thu, 03 May 2007 03:27:14 -0700 (PDT)
Message-ID: <20070503.032714.11077929.davem@davemloft.net>
References: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: dhowells@redhat.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Howells <dhowells@redhat.com>
Date: Thu, 03 May 2007 10:53:15 +0100

> When the user passes in MSG_TRUNC the skb is used after getting freed.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> Signed-off-by: David Howells <dhowells@redhat.com>

Ugh, good catch, applied :-)
