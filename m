From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH RESEND 2/2] update sunrpc to use in-kernel sockets API
Date: Tue, 08 Aug 2006 23:16:42 -0400
Message-ID: <1155093402.5731.35.camel@localhost>
References: <1154991632.11916.6.camel@w-sridhar2.beaverton.ibm.com>
	 <20060807.205910.68157131.davem@davemloft.net>
	 <1155057591.26188.5.camel@w-sridhar2.beaverton.ibm.com>
	 <20060808.170941.71164303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.4]:14027 "EHLO pat.uio.no")
	by vger.kernel.org with ESMTP id S1030436AbWHIDRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 23:17:14 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060808.170941.71164303.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-08 at 17:09 -0700, David Miller wrote:

> Trond, I think the highmem check in xs_sendpages() is completely
> bogus, do you mind if we remove it? :-)
> 
> The socket layer will properly check the device to make sure it
> can handle highmem pages, and if not it will copy the data into
> a low-mem page as-needed.

If the special case is no longer useful, then I for one am quite happy
to get rid of it.

Cheers,
  Trond

