From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Mon, 30 Aug 2004 09:57:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040830075709.GA28454@suse.de>
References: <412A8FB5.4080700@trash.net> <OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com> <20040828231529.051a73cc.davem@davemloft.net> <4132303C.2060807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        David Stevens <dlstevens@us.ibm.com>, davem@redhat.com,
        laforge@netfilter.org, netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4132303C.2060807@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 29, 2004 at 09:36:28PM +0200, Patrick McHardy wrote:
> David S. Miller wrote:
> 
> >I think I agree with David now that I've read through this a few
> >times.  Can someone send me a patch which does this?
> > 
> Attached. The first patch still crashed, we need to prevent new
> fragments from getting queued after the queue is flushed until the
> hook in unregistered.

I was actually going to test-drive my patch today, but you were
faster. Thanks!

Olad
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 
