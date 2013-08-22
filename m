From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH RFC net-next] net: epoll support for busy poll
Date: Thu, 22 Aug 2013 20:11:35 +0000
Message-ID: <20130822201135.GA4088@dcvr.yhbt.net>
References: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Eilon Greenstein <eilong@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	Willem de Bruijn <willemb@google.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eliezer Tamir <eliezer.tamir@linux.intel.com> wrote:
> Performance:
> using sockperf, Intel X520 NICs,
> Supermicro 6026TT-BTF systems with E5-2690 Xeon CPUs
> 100 UDP sockets avg. latency 5.756 (std-dev 0.510)
> 1k  UDP sockets avg. latency 5.780 (std-dev 0.536)
> 10k UDP sockets avg. latency 6.269 (std-dev 0.611)

How does this compare to with normal poll on this system?

In other words, what advantage is there to using epoll instead of poll
when busy looping?

epoll and busy_poll seem to be opposites.  epoll inherently has higher
latency than normal poll, but provides stable performance with many more
FDs.
