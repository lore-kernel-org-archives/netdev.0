From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Kernel 2.6 IPV6 Busted
Date: Sun, 27 Feb 2005 13:35:17 -0800
Message-ID: <20050227133517.578884df.davem@davemloft.net>
References: <200502270928.44402.Info@Quantum-Sci.com>
	<200502271310.59682.Info@quantum-sci.com>
	<42222670.3090002@pobox.com>
	<200502271410.39611.Info@quantum-sci.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Quantum Scientific <Info@quantum-sci.com>
In-Reply-To: <200502271410.39611.Info@quantum-sci.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 27 Feb 2005 14:10:39 -0600
Quantum Scientific <Info@quantum-sci.com> wrote:

> I am skeptical about this assertion that the whole internet needs to be hashed 
> if connection tracking.

Connection tracking and NAT broke entirely the end-to-end host
assumption that used to be valid on the internet.

There are many very important optimizations we've had to disable
by default just in TCP alone because of NAT.
