From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] TSO Reloaded
Date: Fri, 6 May 2005 01:19:54 -0700
Message-ID: <20050506011954.18176751.davem@davemloft.net>
References: <20050504230731.12be1bc3.davem@davemloft.net>
	<20050506043653.GD8255@krispykreme>
	<20050506054516.GE8255@krispykreme>
	<20050505231345.4296d9b5.davem@davemloft.net>
	<20050506071005.GG8255@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20050506071005.GG8255@krispykreme>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 May 2005 17:10:05 +1000
Anton Blanchard <anton@samba.org> wrote:

> Nice work! Its looking much better now.

Great, thanks for testing.

BTW:


> eth0 data: 66 frags: 2892 4

What does this "66 frags" mean?  Is it "tso_segs" from
the SKB?  skb_shinfo(skb)->nr_frags can never be that
large (MAX_SKB_FRAGS is (65536/PAGE_SIZE + 2)) so it
can't be that.
