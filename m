From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/5] [NETLINK]: Fix use after free in netlink_recvmsg
Date: Thu, 03 May 2007 14:27:16 +0200
Message-ID: <1178195236.6891.58.camel@violet>
References: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
	 <20070503.032714.11077929.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:33648 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031191AbXECMcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 08:32:24 -0400
In-Reply-To: <20070503.032714.11077929.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> > When the user passes in MSG_TRUNC the skb is used after getting freed.
> > 
> > Signed-off-by: Patrick McHardy <kaber@trash.net>
> > Signed-off-by: David Howells <dhowells@redhat.com>
> 
> Ugh, good catch, applied :-)

it seems this could be easily exploited and is at least a local DoS. It
should be a candidate for the -stable kernel.

Regards

Marcel


