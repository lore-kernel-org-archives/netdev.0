From: David Lefevre <david.lefevre7@libertysurf.fr>
Subject: Fwd: Re: Ethernet over GRE ?
Date: Tue, 3 Feb 2009 14:15:12 +0100
Message-ID: <20090203131512.GA4722@libertysurf.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from lns-bzn-51f-62-147-205-121.adsl.proxad.net ([62.147.205.121]:44690
	"EHLO doff.ath.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbZBCNey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 08:34:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello, here is a little discussion I had with Stephen about iproute2.
At the end, he has told me to send this to you.
Best regards,
David

----- Forwarded message from Stephen Hemminger <shemminger@vyatta.com> -----
X-Virus-Scanned: amavisd-new at tahiti.vyatta.com
Date: Thu, 22 Jan 2009 14:56:06 +1100
From: Stephen Hemminger <shemminger@vyatta.com>
To: David Lefevre <david.lefevre7@libertysurf.fr>
Subject: Re: Ethernet over GRE ?
In-Reply-To: <20090119114802.GA11895@libertysurf.fr>
Organization: Vyatta
X-Mailer: Claws Mail 3.6.1 (GTK+ 2.14.5; i386-redhat-linux-gnu)
X-Spam-Status: No, score=-2.6 required=3.5 tests=BAYES_00 autolearn=ham
	version=3.2.5
X-Spam-Checker-Version: SpamAssassin 3.2.5 (2008-06-10) on zouzou.doff.net

On Mon, 19 Jan 2009 12:48:02 +0100
David Lefevre <david.lefevre7@libertysurf.fr> wrote:

> On Wed, Jan 07, 2009 at 11:40:33AM -0800, Stephen Hemminger wrote:
> > On Wed, 7 Jan 2009 16:32:45 +0100
> > David Lefevre <david.lefevre7@libertysurf.fr> wrote:
> > 
> > > On Tue, Dec 23, 2008 at 08:38:49AM -0800, Stephen Hemminger wrote:
> > > > On Tue, 9 Dec 2008 12:33:42 +0100
> > > > David Lefevre <david.lefevre7@libertysurf.fr> wrote:
> > > > 
> > > > > 
> > > > > Hi Stephen,
> > > > > looking at the possibility of doing Ethernet over GRE, I've found an interesting discussion on the net : https://kerneltrap.org/mailarchive/linux-netdev/2008/7/14/2454014
> > > > > I've seen this capability was added in the linux kernel, but I was not able to find where :(, even in the 2.6.27.8 release.
> > > > > Is this comming in next releases or already usable ?
> > > > > Kind regards,
> > > > > David
> > > > 
> > > > It will be in 2.6.28, this patch is the start of it.
> > > > 
> > > > commit e1a8000228e16212c93b23cfbed4d622e2ec7a6b
> > > > Author: Herbert Xu <herbert@gondor.apana.org.au>
> > > > Date:   Thu Oct 9 12:00:17 2008 -0700
> > > > 
> > > >     gre: Add Transparent Ethernet Bridging
> > > >     
> > > >     This patch adds support for Ethernet over GRE encapsulation.
> > > >     This is exposed to user-space with a new link type of "gretap"
> > > >     instead of "gre".  It will create an ARPHRD_ETHER device in
> > > >     lieu of the usual ARPHRD_IPGRE.
> > > >     
> > > >     Note that to preserver backwards compatibility all Transparent
> > > >     Ethernet Bridging packets are passed to an ARPHRD_IPGRE tunnel
> > > >     if its key matches and there is no ARPHRD_ETHER device whose
> > > >     key matches more closely.
> > > >     
> > > >     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > > >     Signed-off-by: David S. Miller <davem@davemloft.net>
> > > 
> > > Hi Stephen,
> > > I think there a little stuff to do in the iproute2 source code to activate this gretap mode, isn't it ?
> > > David
> > 
> > There is, and I just put into the git version yesterday
> 
> Hi Stephen,
> thanks for the new release of iproute2 (corresponding to 2.6.28).
> I'm still confused : I can create a "gretap" interface and add it to a bridge (with brtcl addif) but, in that case, I don't know how to use this interface as a tunnel (GRE). And if I set up a tunnel, I cannot add it as an interface in the bridge.
> Am I missing something ?
> Regards,
> David

send to Herbert Xu and netdev@vger.kernel.org

> 

----- End forwarded message -----
