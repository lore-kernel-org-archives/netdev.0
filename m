From: David Miller <davem@davemloft.net>
Subject: Re: IPV6 source routing patch is still broken?
Date: Thu, 26 Apr 2007 15:04:34 -0700 (PDT)
Message-ID: <20070426.150434.91313967.davem@davemloft.net>
References: <46311F76.9040803@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: cebbert@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42084
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755126AbXDZWE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 18:04:27 -0400
In-Reply-To: <46311F76.9040803@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chuck Ebbert <cebbert@redhat.com>
Date: Thu, 26 Apr 2007 17:53:58 -0400

> And what does this do?
> 
> +	switch (hdr->type) {
> +#ifdef CONFIG_IPV6_MIP6
> +		break;
> +#endif
> 
> break by itself like that doesn't do anything. If it did
> then people with mobile ipv6 enabled would always accept all
> source routing. (They should at least know that's a problem.)

We are aware of this part already, and I've sent the fix to
the -stable folks and Linus so we can figure out how to deal
with this and the netlink OOPS'er too.

To be honest I don't blame anyone but the compiler, it shouldn't
accept that code without at least a warning.
