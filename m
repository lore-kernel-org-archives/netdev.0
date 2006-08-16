From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH?] tcp and delayed acks
Date: Wed, 16 Aug 2006 14:15:37 -0700 (PDT)
Message-ID: <20060816.141537.85688789.davem@davemloft.net>
References: <20060816205532.GF9519@kvack.org>
	<20060816121112.0c181ac3@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bcrl@kvack.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:62627
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932218AbWHPVQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 17:16:22 -0400
To: shemminger@osdl.org
In-Reply-To: <20060816121112.0c181ac3@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Wed, 16 Aug 2006 12:11:12 -0700

> What ethernet hardware? The defaults are often not big enough
> for full speed on gigabit hardware. I need increase rmem/wmem to allow
> for more buffering. 

Current kernels allow the TCP send and receive socket buffers
to grow up to at least 4MB in size, how much more do you need?

tcp_{w,r}mem[2] will now have a value of at least 4MB, see
net/ipv4/tcp.c:tcp_init().
