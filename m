From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] I/O space write barrier
Date: Wed, 29 Sep 2004 13:50:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929135029.38444afd.davem@davemloft.net>
References: <200409271103.39913.jbarnes@engr.sgi.com>
	<20040929103646.GA4682@sgi.com>
	<20040929133500.59d78765.davem@davemloft.net>
	<200409291343.55863.jbarnes@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gnb@sgi.com, akpm@osdl.org, linux-kernel@vger.kernel.org, jeremy@sgi.com,
        johnip@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesse Barnes <jbarnes@engr.sgi.com>
In-Reply-To: <200409291343.55863.jbarnes@engr.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 13:43:55 -0700
Jesse Barnes <jbarnes@engr.sgi.com> wrote:

> The patch that actually implements mmiowb() already does this, I think Greg 
> just used his patch for testing.  The proper way to do it of course is to 
> just use mmiowb() where needed in tg3 after the write barrier patch gets in.

Perfect, please send me a tg3 patch once the mmiowb() bits
go into the tree.

Thanks a lot.
