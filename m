From: Jason Baron <jbaron@redhat.com>
Subject: Re: [PATCH 0/5] dev_<level> and dynamic_debug cleanups
Date: Mon, 10 Sep 2012 16:56:06 -0400
Message-ID: <20120910205605.GB2406@redhat.com>
References: <cover.1345978012.git.joe@perches.com>
 <20120906175158.GB9786@redhat.com>
 <1346957026.13424.5.camel@joe2Laptop>
 <20120907145235.GA18673@redhat.com>
 <1347030721.13424.22.camel@joe2Laptop>
 <20120907153542.GB18673@redhat.com>
 <1347069350.13424.28.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jim Cromie <jim.cromie@gmail.com>, Kay Sievers <kay@vrfy.org>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1347069350.13424.28.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 07, 2012 at 06:55:50PM -0700, Joe Perches wrote:
> On Fri, 2012-09-07 at 11:35 -0400, Jason Baron wrote:
> > If nobody else thinks this patch is better, let's at least add a comment in
> > __dev_printk() and __netdev_printk() to fix dynamic debug, if these are changed.
> 
> Or maybe make dynamic_emit_prefix a public function
> and move the __dynamic_<foo>_printk functions to
> nearby the __<foo>_printk functions so it's easier to
> see that changing one requires the other to change.
> 

ok, that makes sense to me.

Thanks,

-Jason
