From: mcgrof@ruslug.rutgers.edu (Luis R. Rodriguez)
Subject: Re: Updated WE-18 (WPA) proposal
Date: Tue, 31 Aug 2004 04:54:58 -0400
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040831085458.GD31207@ruslug.rutgers.edu>
References: <20040830045441.GA7415@jm.kir.nu>
	<20040830165026.GD29492@bougret.hpl.hp.com>
	<413363CB.7060807@pobox.com>
	<20040830174215.GA32132@bougret.hpl.hp.com>
	<41336A28.9010608@pobox.com>
	<20040830220105.GY22126@ruslug.rutgers.edu>
	<4133A811.1010009@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Jouni Malinen <jkmaline@cc.hut.fi>,
	hostap@shmoo.com, "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	Pedro Ramalhais <ramalhais@serrado.net>, jt@hpl.hp.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4133A811.1010009@pobox.com>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 30, 2004 at 06:20:01PM -0400, Jeff Garzik wrote:
> Luis R. Rodriguez wrote:
> >On Mon, Aug 30, 2004 at 01:55:52PM -0400, Jeff Garzik wrote:
> >
> >>Jean Tourrilhes wrote:
> >
> >
> ><-- snip -->
> >
> >>>	Also, I'm not clear how the stuff in wireless-2.6 is supposed
> >>>to trickle into the other trees (netdev-2.6, -mm and Linus's), and how
> >>>to better link it with the CVS of the various drivers involved.
> >>
> >>Less of a trickle than a flood:  wireless-2.6 should be the target for 
> >>development of shared wireless stack code.  As several drivers are 
> >>currently using bits of HostAP, for example, wireless-2.6 should be a 
> >>focal point for patches that modify these drivers to instead share the 
> >>same code.
> >>
> >>Once this generic work is done, it would get pushed all at once to 
> >>netdev-2.6, where it would receive testing in -mm.  Then, later, pushed 
> >>to mainline.
> >>
> >>	Jeff
> >
> >
> >Beides wpa_supplicant from hostap code (which is actually going into
> >WE18) what other code re-use is on the roadmap as of yet for wireless-2.6?
> 
> Intel Centrino driver is re-using chunks of HostAP, and I'm looking at 
> doing so for the RealTek 8180 driver I am about to publish.

Can someone elaborate on what "chunks" the centrino driver is using
from hostap?

Jeff what aspects are you looking to re-use from hostap?

I guess we at prism54 should also see what we can re-use too then.
Our next driver (a softmac driver) will have a lot more code since the
MAC will need to be implemented on the driver side -- I'm not yet sure
of the exact details as I haven't grep'd through the available code yet
I'm wondering though -- are there any other softmac drivers out there,
or to come soon?

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
