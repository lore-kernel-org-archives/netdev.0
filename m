From: Stefan Schmidt <zaphodb@zaphods.net>
Subject: Re: 2.6.10-rc1-mm4 -1 EAGAIN after allocation failure was: Re: Kernel 2.6.9 Multiple Page Allocation Failures
Date: Wed, 10 Nov 2004 13:06:24 +0100
Message-ID: <20041110120624.GF28163@zaphods.net>
References: <20041104181856.GE28163@zaphods.net> <20041109164113.GD7632@logos.cnet> <20041109223558.GR1309@mail.muni.cz> <20041109144607.2950a41a.akpm@osdl.org> <20041109235201.GC20754@zaphods.net> <20041110012733.GD20754@zaphods.net> <20041109173920.08746dbd.akpm@osdl.org> <20041110020327.GE20754@zaphods.net> <419197EA.9090809@cyberone.com.au> <20041110102854.GI20754@zaphods.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, marcelo.tosatti@cyclades.com,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nick Piggin <piggin@cyberone.com.au>
Content-Disposition: inline
In-Reply-To: <20041110102854.GI20754@zaphods.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 10, 2004 at 11:28:54AM +0100, Stefan Schmidt wrote:
> > Can you try the following patch, please? It is diffed against 2.6.10-rc1,
> > but I think it should apply to -mm kernels as well.
I did. No apparent change with mm4 and vm.min_free_kbytes = 8192. I will try
latest bk next.

> I unset CONFIG_PACKET_MMAP and i suppose this could have this kind of effect
> on high connection rates.
> I set it back to CONFIG_PACKET_MMAP=y and if the application does not freeze
> for some hours at this load we can blame at least this issue (-1 EAGAIN) on
> that parameter.
Nope, that didn't change anything, still getting EAGAIN, checked two times.

	Stefan
