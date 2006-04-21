From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH 0/10] [IOAT] I/OAT patches repost
Date: Thu, 20 Apr 2006 23:42:50 -0500
Message-ID: <20060421044250.GO26746@pb15.lixom.net>
References: <20060420213305.GK26746@pb15.lixom.net> <20060420.172742.132879746.davem@davemloft.net> <20060421030426.GM26746@pb15.lixom.net> <20060420.204200.103377406.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: olof@lixom.net, andrew.grover@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:14298 "EHLO mail.lixom.net")
	by vger.kernel.org with ESMTP id S932094AbWDUEnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 00:43:45 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060420.204200.103377406.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 08:42:00PM -0700, David S. Miller wrote:

> This is basically why none of the performance gains add up to me.  I
> am thus very concerned that the current non-cache-warming
> implmentation may fall flat performance wise.

Ok, I buy your arguments. It does seems unlikely that a DMA offload
without cache warmth will be a net gain. More performance data is
definitely be required.

After digging after PDFs, it seems as the Freescale 85xx (at least,
probably earlier models as well) can warm L2 for the DMA destination
data. However, I don't have any hardware with it to play around
with for benchmarking to see what cache warming might bring (back),
performance-wise.

I think there is still use for a common multi-function DMA framework
across platforms and client components, even if net receive doesn't end
up being {a,the first} user.


-Olof
