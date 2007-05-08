From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 25/29] xen: Add the Xen virtual network device driver.
Date: Tue, 08 May 2007 16:42:54 +1000
Message-ID: <1178606574.7286.3.camel@localhost.localdomain>
References: <20070504232051.411946839@goop.org>
	<20070504232121.492190579@goop.org>
	<20070505091624.GA8890@infradead.org> <463F9608.40803@goop.org>
	<1178577322.28438.16.camel@localhost.localdomain>
	<464018F2.7050409@goop.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@sous-sol.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Jeff Garzik <jeff@garzik.org>, Ian Pratt <ian.pratt@xensource.com>,
        netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>, virtualization@lists.osdl.org,
        Stephen Hemminger <shemminge@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <464018F2.7050409@goop.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-05-07 at 23:30 -0700, Jeremy Fitzhardinge wrote:
> Rusty Russell wrote:
> > Looks good, you can slightly improve it to be the model use of new
> > module_param types by calling your functions param_set_rx_mode and
> > param_get_rx_mode, then simply using "module_param(rx_mode, rx_mode,
> > 0400)"
> >   
> 
> Cute.  I tried it out, but it doesn't yield an obvious improvement:

Of course not, but it's the Right Way!

Thanks,
Rusty.
