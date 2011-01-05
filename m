From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv4: IP defragmentation must be ECN aware
Date: Wed, 5 Jan 2011 09:13:40 -0800
Message-ID: <20110105091340.3f8833ef@nehalam>
References: <1294186431.3420.19.camel@edumazet-laptop>
	<1294235942.2775.191.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47133 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170Ab1AERNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jan 2011 12:13:43 -0500
In-Reply-To: <1294235942.2775.191.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jan 2011 14:59:02 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> +
> +static inline int ip4_frag_ecn(int tos)

Since tos is only a byte, this should be:

static inline u8 ip4_frag_ecn(u8 tos)


-- 
