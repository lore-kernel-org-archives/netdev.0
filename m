From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Prism54 AP WPA using Hostap and WDS
Date: Mon, 8 Nov 2004 10:16:18 -0500
Message-ID: <20041108151618.GW388@ruslug.rutgers.edu>
References: <20041104032219.GU388@ruslug.rutgers.edu>
	<20041105162037.GN388@ruslug.rutgers.edu>
	<20041105162811.GP388@ruslug.rutgers.edu>
	<20041108122922.GV388@ruslug.rutgers.edu>
	<20041108141751.GM23338@Redstar.dorchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, Jouni Malinen <jkmaline@cc.hut.fi>,
	prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: Joerg Dorchain <joerg@dorchain.net>
Content-Disposition: inline
In-Reply-To: <20041108141751.GM23338@Redstar.dorchain.net>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 08, 2004 at 03:17:51PM +0100, Joerg Dorchain wrote:
> On Mon, Nov 08, 2004 at 07:29:22AM -0500, Luis R. Rodriguez wrote:
> > > 
> > > > Access Point WPA support (NEW) (requires hostapd)
> > > > Access Point WDS Support (NEW)
> > > 
> > > For your convenience, here are some links for those of you wishing to test:
> > > 
> > > http://prism54.org/pub/linux/snapshot/tars/prism54-cvs-latest.tar.bz2
> > 
> > The kernel patches were broken for WDS support as I forgot to include
> > isl_wds.[ch] in the patch process. I have now fixed this in my script.
> > The patches should now work.
> 
> The built outside the kernel tree (linus 2.6.9) still has not changed.
> There is still a include for isl_wds.h missing in islpci_eth.c, and
> "dev_alloc" is still an undefined symbol.
> 
> Bye,
> 
> Joerg

Joerg,

thanks yes this was the second thing I was going to look into. I'll work
on it next. Thanks,

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
