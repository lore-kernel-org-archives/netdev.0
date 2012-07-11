From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ipv6: optimize ipv6 addresses compares
Date: Tue, 10 Jul 2012 20:59:57 -0700
Message-ID: <1341979197.13724.38.camel@joe2Laptop>
References: <1341978558.3265.6609.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54229 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754202Ab2GKD75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 23:59:57 -0400
In-Reply-To: <1341978558.3265.6609.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-11 at 05:49 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On 64 bit arches having efficient unaligned accesses (eg x86_64) we can
> use long words to reduce number of instructions for free.

Thanks Eric.  This looks very sensible.
