From: "David S. Miller" <davem@davemloft.net>
Subject: Re: gettimeofday scalability
Date: Tue, 5 Oct 2004 11:35:12 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041005113512.45ab0a31.davem@davemloft.net>
References: <4162CD76.4070204@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mingo@elte.hu, andrea@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <4162CD76.4070204@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 05 Oct 2004 17:36:06 +0100
P@draigBrady.com wrote:

> So can anyone summarise the relative merits of these locking
> mechanisms, before I start benchmarking?

Seq locks plus the timer interpolator layer found in 2.6.x kernels
is the most scalable gettimeofday() implementation currently.
