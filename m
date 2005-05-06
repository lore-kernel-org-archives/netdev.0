From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] TSO Reloaded
Date: Fri, 6 May 2005 15:45:16 +1000
Message-ID: <20050506054516.GE8255@krispykreme>
References: <20050504230731.12be1bc3.davem@davemloft.net> <20050506043653.GD8255@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050506043653.GD8255@krispykreme>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi,

With a 9000 byte MTU I see page sized frags as expected. There are still
some pages broken in two which is interesting.

Anton

data: 66 frags: 3584 4096 1268 2816 4096 2032 4
data: 66 frags: 2048 4096 2804 1280 4096 3568 4
data: 66 frags: 512 4096 4096 244 3840 4096 1008 4
data: 66 frags: 3072 4096 1780 2304 4096 2544 4
data: 66 frags: 1536 4096 3316 768 4096 4080 4
data: 66 frags: 4096 4096 756 3328 4096 1520 4
data: 66 frags: 2560 4096 2292 1792 4096 3056 4
data: 66 frags: 1024 4096 3828 256 4096 4096 496 4
data: 66 frags: 3584 4096 1268 2816 4096 2032 4
data: 66 frags: 2048 4096 2804 1280 4096 3568 4
data: 66 frags: 512 4096 4096 244 3840 4096 1008 4
data: 66 frags: 3072 4096 1780 2304 4096 2544 4
data: 66 frags: 1536 4096 3316 768 4096 4080 4
data: 66 frags: 4096 4096 756 3328 4096 1520 4
data: 66 frags: 2560 4096 2292 1792 4096 3056 4
data: 66 frags: 1024 4096 3828 256 4096 4096 496 4
data: 66 frags: 3584 4096 1268 2816 4096 2032 4
