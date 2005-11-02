From: Mikhail Gusarov <dottedmag@dottedmag.net>
Subject: Re: ancient ieee80211/ipw2200 drivers in recent kernel (2.6.14)
Date: Wed, 02 Nov 2005 12:54:09 +0600
Message-ID: <871x1zk0a6.fsf@vertex.dottedmag.net>
References: <873bmg9sym.fsf@vertex.dottedmag.net>
	<20051102020903.GG29803@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: debian-kernel@lists.debian.org, NetDev <netdev@vger.kernel.org>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
To: Mikhail Gusarov <dottedmag@dottedmag.net>
In-Reply-To: <20051102020903.GG29803@verge.net.au> (horms@verge.net.au's
	message of "Wed, 2 Nov 2005 11:09:05 +0900")
Resent-Message-ID: <PSORqD.A.KQD.AbGaDB@murphy>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org


You (horms@verge.net.au) wrote:

 >> I've encountered the problem with 2.6.14 kernels: they are shipped
 >> with ancient version of ipw2200 drivers (1.0.0 while current
 >> version is 1.0.7) and ancient version of ieee80211 subsystem
 >> (copyrighted as 2004, so also outdated).
 >> 
 >> This breaks compilation of module from ipw2200-source package
 >> (because it links against in-kernel ieee80211).

 H> I assume the problem you are seeing is a headers problem.

Ah, yes. The other problem is two copies ipw2200.ko & ieee80211*.ko
modules being installed: the ones included in kernel and others
compiled as external modules. I suppose this may lead to the problems
with depmod.

 >> Is there way to modularize builds to exclude ieee80211 or just
 >> disable it (along with ipw2200) because it is outdated and current
 >> vesion is shipped in ieee80211-source package?

 H> Probably the best place to start is to ping netdev to find out if
 H> there are any plans to update IPW2200 in Linus's tree. I've CCed
 H> that list, hopefully someone can shed some light on this.

So, having in mind the two levels of 'stablenesss': kernel
'stableness' and modules 'stableness' :) we should find the way to
exclude discussed modules from the build, because in-kernel versions
will always be, erm..., slightly (1.0.0 is mentioned only as 'stone
age' in the mailing list of ipw2200 developers) outdated due to fact
integration and testing gets some time in upstream kernels. I propose
just to disable compilation of this drivers: everyone will be able to
compile the recent version using ipw2200-source we provide.

-- 
Mikhail Gusarov
ICQ UIN: 111575219
JID: dottedmag@jabber.dottedmag.net
