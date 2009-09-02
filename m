From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bonding: use compare_ether_addr_64bits()
 in ALB
Date: Tue, 01 Sep 2009 17:44:06 -0700 (PDT)
Message-ID: <20090901.174406.160495063.davem@davemloft.net>
References: <4A9D4C56.1090804@gmail.com>
	<20090901181834.GB3209@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, fubar@us.ibm.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40459
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755428AbZIBAnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:43:51 -0400
In-Reply-To: <20090901181834.GB3209@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 1 Sep 2009 20:18:35 +0200

> Tue, Sep 01, 2009 at 06:31:18PM CEST, eric.dumazet@gmail.com wrote:
>>We can speedup ether addresses compares using compare_ether_addr_64bits()
>>instead of memcmp(). We make sure all operands are at least 8 bytes long and
>>16bits aligned (or better, long word aligned if possible)
>>
>>Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
...
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>

Applied.
