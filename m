From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: Remove uses of seq_<foo> return
 values
Date: Wed, 18 Mar 2015 18:02:27 +0100
Message-ID: <20150318170227.GA3978@salvia>
References: <1426530317.23897.27.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426530317.23897.27.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 16, 2015 at 11:25:17AM -0700, Joe Perches wrote:
> The seq_printf/seq_puts/seq_putc return values, because they
> are frequently misused, will eventually be converted to void.
> 
> See: commit 1f33c41c03da ("seq_file: Rename seq_overflow() to
>      seq_has_overflowed() and make public")
> 
> Miscellanea:
> 
> o realign arguments

Applied, thanks.
