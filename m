From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tun: orphan an skb on tx
Date: Tue, 03 Feb 2015 16:19:55 -0800 (PST)
Message-ID: <20150203.161955.1916354877509427788.davem@davemloft.net>
References: <1422826183.11044.72.camel@infradead.org>
	<20150201.210716.588479604128207372.davem@davemloft.net>
	<1422862030.11044.86.camel@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com, jan.kiszka@siemens.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	qemu-devel@nongnu.org
To: dwmw2@infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422862030.11044.86.camel@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Woodhouse <dwmw2@infradead.org>
Date: Mon, 02 Feb 2015 07:27:10 +0000

> I'm guessing you don't want to push the *whole* management of the TLS
> control connection *and* the UDP transport, and probing the latter with
> keepalives, into the kernel? I certainly don't :)

Whilst Herbert Xu and I have discussed in the past supporting
automatic SSL handling of socket data during socket writes in the
kernel, doing TLS stuff would be a bit of a stretch :-)
