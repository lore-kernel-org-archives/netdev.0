From: Andi Kleen <ak@colin2.muc.de>
Subject: Re: [PATCH] Convert pppoe to new style protocol
Date: 18 Jun 2003 14:51:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618125159.GA15238@colin2.muc.de>
References: <20030617220420.GA1169@averell> <20030617.150751.52901849.davem@redhat.com> <20030618080118.GC23037@wotan.suse.de> <20030618092126.A28100@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, ak@muc.de, netdev@oss.sgi.com,
   mostrows@speakeasy.net, paulus@au.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Wed, 18 Jun 2003 14:51:59 +0200
To: Werner Almesberger <wa@almesberger.net>
Content-Disposition: inline
In-Reply-To: <20030618092126.A28100@almesberger.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 18, 2003 at 09:21:26AM -0300, Werner Almesberger wrote:
> On Tue, Jun 17, 2003 at 03:07:51PM -0700, David S. Miller wrote:
> > Please don't add new skb_linearize() users, I'm trying
> > to make that only local to net/core/dev.c
> 
> I know you find documentation unmanly, but maybe ...

But what is the replacement? For moving over whole subsystems to 
non linear skbs it's a bit late in the release...

And the "legacy protocol" setting cannot be used anymore because
it triggers a printk for every packet on a SMP kernel.

-Andi
