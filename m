From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH -next 2/2] seq_putc: Convert to return void and convert
 uses too.
Date: Wed, 12 Nov 2014 13:29:00 +0100
Message-ID: <20141112122900.GA1542@salvia>
References: <cover.1415645476.git.joe@perches.com>
 <56c4c0d5ec721134cff4913e5e3f8923169c35ef.1415645477.git.joe@perches.com>
 <20141111134740.GB2567@pathway.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Corey Minyard <minyard@acm.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	openipmi-developer@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Petr Mladek <pmladek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141111134740.GB2567@pathway.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 11, 2014 at 02:47:40PM +0100, Petr Mladek wrote:
> On Mon 2014-11-10 10:58:57, Joe Perches wrote:
> > Using the return value of seq_putc is error-prone, so
> > make it return void instead.
> > 
> > Reverse the logic in seq_putc to make it like seq_puts.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Reviewed-by: Petr Mladek <pmladek@suse.cz>
> 
> The changes are correct. The show() functions should return 0
> even when there is an overflow. They are called by traverse()
> from seq_read() that might increase the buffer size and try again.

Just in case you need this for the netfilter chunks:

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

Thanks.
