From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Do not include linux/irq.h from linux/netpoll.h
Date: Tue, 16 Mar 2004 19:31:12 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316193112.A4796@infradead.org>
References: <1079369568.19012.100.camel@icampbell-debian> <20040316001141.C29594@flint.arm.linux.org.uk> <20040316192247.A7886@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>, Ian Campbell <icampbell@arcom.com>,
        netdev@oss.sgi.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20040316192247.A7886@flint.arm.linux.org.uk>; from rmk+lkml@arm.linux.org.uk on Tue, Mar 16, 2004 at 07:22:47PM +0000
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 16, 2004 at 07:22:47PM +0000, Russell King wrote:
> So how do we solve this problem.  Should I just merge this change and
> ask you to pull it?  I think that's rather impolite though.
> 
> Or should I send a BK cset which removes include/linux/irq.h entirely,
> thereby fixing _my_ problem (though it'll break everyone elses build.) 8)

What about moving it to asm-generic now?  linux/irq.h never was a public
API so the stable API in 2.6 thing doesn't count.  And it's fix the confusing
for real.
