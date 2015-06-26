From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [-next] fib_dump_info() suspicious RCU usage
Date: Fri, 26 Jun 2015 10:24:48 -0400
Message-ID: <20150626142447.GV588@gospo.home.greyhouse.net>
References: <20150626093540.GA4989@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150626093540.GA4989@swordfish>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 26, 2015 at 06:35:40PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> Since 0eeb075fad736 ('net: ipv4 sysctl option to ignore routes when nexthop
> link is down') fib_dump_info() and fib_sync_up() are using __in_dev_get_rcu(),
> which requires (missing) RCU read side protection.

Yep, I can reproduce this now.  Thanks for reporting.

I'll take a look and should be able to post an easy fix quickly.
