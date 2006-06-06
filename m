From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Right prototype of __raw_v4_lookup()
Date: Mon, 05 Jun 2006 21:07:07 -0700 (PDT)
Message-ID: <20060605.210707.39159307.davem@davemloft.net>
References: <20060527210932.GB7267@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46286
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751095AbWFFEHI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 00:07:08 -0400
To: adobriyan@gmail.com
In-Reply-To: <20060527210932.GB7267@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Sun, 28 May 2006 01:09:32 +0400

> All users pass 32-bit values as addresses and internally they're compared with
> 32-bit entities. So, change "laddr" and "raddr" types to __be32.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.

Doesn't this mean that, at least eventually, we should change
the address members of inet_sock to __be32 as well?
