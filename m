From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: fix dst leakage caused by rt6_cow()
Date: Mon, 18 Aug 2003 03:45:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818034505.08182f5b.davem@redhat.com>
References: <Pine.LNX.4.44.0308051530560.30970-200000@rhea.tcs.hut.fi>
	<Pine.LNX.4.44.0308051642460.31172-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308051642460.31172-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 11:13:13 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> since rt6_cow() calls dst_hold() it looks like we're leaking refcounts in
> three places in route.c. The patch below should fix this.

You are absolutely correct.

Patch applied, thanks.
