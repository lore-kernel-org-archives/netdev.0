From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/5] [NETLINK]: Fix use after free in netlink_recvmsg
Date: Thu, 03 May 2007 14:46:29 +0200
Message-ID: <4639D9A5.3060401@trash.net>
References: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>	 <20070503.032714.11077929.davem@davemloft.net> <1178195236.6891.58.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dhowells@redhat.com,
	akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1178195236.6891.58.camel@violet>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcel Holtmann wrote:
> it seems this could be easily exploited and is at least a local DoS. It
> should be a candidate for the -stable kernel.


The bug got introduced in 2.6.21-git, so -stable is not affected.
