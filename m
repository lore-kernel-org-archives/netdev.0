From: "David S. Miller" <davem@redhat.com>
Subject: Re: Allow IP header alignment to be overriden
Date: Tue, 15 Jun 2004 21:37:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040615213723.21e825d0.davem@redhat.com>
References: <20040611012727.GA27672@krispykreme>
	<20040610223549.5e9ad025.davem@redhat.com>
	<1086939562.3657.10.camel@sfeldma-mobl2.dsl-verizon.net>
	<20040611142336.GE27672@krispykreme>
	<20040612111218.783f587d.davem@redhat.com>
	<20040615233423.GC3228@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sfeldma@pobox.com, netdev@oss.sgi.com, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, leonid.grossman@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040615233423.GC3228@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jun 2004 09:34:23 +1000
Anton Blanchard <anton@samba.org> wrote:

> > Yes.  Please add a paragraph to that comment explaining what "unaligned
> > CPU cost" really means, ie. that the IP/TCP header members are going to
> > be accessed with alignment less than the types might require on a given
> > architecture.
> > 
> > Then I'll apply this and we can start beating up the drivers.
> 
> How does this look? The s2io, ixgb and e1000 drivers are converted.

Works for me, applied.

Thanks Anton.
