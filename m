From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/2] add iovnl netlink support
Date: Wed, 21 Apr 2010 23:48:49 -0700 (PDT)
Message-ID: <20100421.234849.51685723.davem@davemloft.net>
References: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com>
	<20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46028
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753229Ab0DVGso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 02:48:44 -0400
In-Reply-To: <20100419191807.10423.84600.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Mon, 19 Apr 2010 12:18:07 -0700

> +#define IOVNL_PROTO_VERSION 1
> +

Please delete this in the final version, the macro isn't even used by
the code.

We don't do protocol versioning in netlink.  Instead we get the base
stuff solid from the beginning, and then if something needs fixing up
we handle this using new attributes in a way which is both backward
and forward compatible.

Thanks.
