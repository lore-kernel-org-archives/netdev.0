From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Sun, 01 Feb 2015 12:19:48 -0800 (PST)
Message-ID: <20150201.121948.998046471405758397.davem@davemloft.net>
References: <1422789633.11044.18.camel@infradead.org>
	<20150201122611.GA8883@redhat.com>
	<1422797630.11044.32.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com, jan.kiszka@siemens.com, paul.moore@hp.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qemu-devel@nongnu.org
To: dwmw2@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422797630.11044.32.camel@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Sun, 01 Feb 2015 13:33:50 +0000

> Of course, now I'm looking closely at the path these packets take to
> leave the box, it starts to offend me that they're being passed up to
> userspace just to encrypt them (as DTLS or ESP) and then send them back
> down to the kernel on a UDP socket. The kernel already knows how to
> {en,de}crypt ESP, and do the sequence number checking on incoming
> packets.

It's funny, I thought we had an IPSEC stack....
