From: "David S. Miller" <davem@davemloft.net>
Subject: Re: some TSO analysis
Date: Thu, 11 Nov 2004 10:26:22 -0800
Message-ID: <20041111102622.19fb1a22.davem@davemloft.net>
References: <20041111050608.GG1922@krispykreme.ozlabs.ibm.com>
	<E1CS9Fm-0004hC-00@gondolin.me.apana.org.au>
	<20041111083647.GA20769@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20041111083647.GA20769@krispykreme.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Nov 2004 19:36:47 +1100
Anton Blanchard <anton@samba.org> wrote:

> Im interested if the divisor of 8 was based on some testing, or if we
> can tune the default a bit. It would be nice for TSO to kick in on
> normal workloads (like web serving).

It was the best compromise found between performance and burstyness.

If you set it too small, you get large bursts of TSO created
frames which is very undesirable.
