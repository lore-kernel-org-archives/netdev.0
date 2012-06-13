From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net-next: add dev_loopback_xmit() to avoid
 duplicate code
Date: Tue, 12 Jun 2012 18:52:20 -0700 (PDT)
Message-ID: <20120612.185220.1209592106225618525.davem@davemloft.net>
References: <1339532195.2701.8.camel@Thor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, edumazet@google.com, jpirko@redhat.com,
	mirq-linux@rere.qmqm.pl, bhutchings@solarflare.com
To: michel@digirati.com.br
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339532195.2701.8.camel@Thor>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michel Machado <michel@digirati.com.br>
Date: Tue, 12 Jun 2012 16:16:35 -0400

> Add dev_loopback_xmit() in order to deduplicate functions
> ip_dev_loopback_xmit() (in net/ipv4/ip_output.c) and
> ip6_dev_loopback_xmit() (in net/ipv6/ip6_output.c).
> 
> I was about to reinvent the wheel when I noticed that
> ip_dev_loopback_xmit() and ip6_dev_loopback_xmit() do exactly what I
> need and are not IP-only functions, but they were not available to reuse
> elsewhere.
> 
> ip6_dev_loopback_xmit() does not have line "skb_dst_force(skb);", but I
> understand that this is harmless, and should be in dev_loopback_xmit().
> 
> Signed-off-by: Michel Machado <michel@digirati.com.br>

Applied.
