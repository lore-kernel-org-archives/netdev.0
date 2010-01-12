From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per
 interface
Date: Mon, 11 Jan 2010 18:03:45 -0600
Message-ID: <1263254625.29868.4777.camel@calx>
References: <4B4630C0.6090206@gmail.com> <4B467A4D.9070708@gmail.com>
	 <1263252108.29868.4774.camel@calx>
	 <20100111.155912.68138954.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: danborkmann@googlemail.com, linux-kernel@vger.kernel.org,
	jmoyer@redhat.com, netdev@vger.kernel.org, netdev@oss.sgi.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753938Ab0ALAD6@vger.kernel.org>
In-Reply-To: <20100111.155912.68138954.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-01-11 at 15:59 -0800, David Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Mon, 11 Jan 2010 17:21:48 -0600
> 
> > Looks pretty good. Dave?
> > 
> > Acked-by: Matt Mackall <mpm@selenic.com>
> 
> I don't like the loop for RX ARP processing.
> 
> The packet contents aren't going to change, so doing basic
> packet validation inside of the "for each RX client" loop
> of arp_reply() doesn't make any sense.

True. Dan, please help our poor compilers with some manual loop
invariant motion.

-- 
http://selenic.com : development and support for Mercurial and Linux
