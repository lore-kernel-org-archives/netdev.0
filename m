From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per
 interface
Date: Mon, 11 Jan 2010 15:59:12 -0800 (PST)
Message-ID: <20100111.155912.68138954.davem@davemloft.net>
References: <4B4630C0.6090206@gmail.com>
	<4B467A4D.9070708@gmail.com>
	<1263252108.29868.4774.camel@calx>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: danborkmann@googlemail.com, linux-kernel@vger.kernel.org,
	jmoyer@redhat.com, netdev@vger.kernel.org, netdev@oss.sgi.com
To: mpm@selenic.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753547Ab0AKX7G@vger.kernel.org>
In-Reply-To: <1263252108.29868.4774.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Mon, 11 Jan 2010 17:21:48 -0600

> Looks pretty good. Dave?
> 
> Acked-by: Matt Mackall <mpm@selenic.com>

I don't like the loop for RX ARP processing.

The packet contents aren't going to change, so doing basic
packet validation inside of the "for each RX client" loop
of arp_reply() doesn't make any sense.
