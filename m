From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH alt.2] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 6 Jan 2010 06:49:57 -0800
Message-ID: <20100106064957.3be271b8@nehalam>
References: <20100105230746.GA6612@del.dom.local>
	<4B43F72C.9090004@majjas.com>
	<20100106072208.GA6711@ff.dom.local>
	<20100106091532.GA10201@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Breuer <mbreuer@majjas.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32778 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755767Ab0AFOu0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 09:50:26 -0500
In-Reply-To: <20100106091532.GA10201@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 6 Jan 2010 09:15:32 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> tpacket_snd() can change and kfree an skb after dev_queue_xmit(),
> which is illegal.
> 
> With debugging by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Reported-by: Michael Breuer <mbreuer@majjas.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Good catch.
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
