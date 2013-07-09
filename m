From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH net-next] net: rename low latency sockets functions to
 busy poll
Date: Tue, 9 Jul 2013 16:25:14 -0600
Message-ID: <20130709162514.062f1361@lwn.net>
References: <20130708132034.17639.4396.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Mortons <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130708132034.17639.4396.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 08 Jul 2013 16:20:34 +0300
Eliezer Tamir <eliezer.tamir@linux.intel.com> wrote:

> Rename POLL_LL to POLL_BUSY_LOOP.

So pardon me if I speak out of turn, but it occurs to me to
wonder...should the SO_LL socket option be renamed in a similar fashion
before this interface escapes into the wild?

Thanks,

jon
