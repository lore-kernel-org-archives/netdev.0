From: Horms <horms@verge.net.au>
Subject: Re: ancient ieee80211/ipw2200 drivers in recent kernel (2.6.14)
Date: Wed, 2 Nov 2005 11:09:05 +0900
Message-ID: <20051102020903.GG29803@verge.net.au>
References: <873bmg9sym.fsf@vertex.dottedmag.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: debian-kernel@lists.debian.org, NetDev <netdev@vger.kernel.org>
Return-path: <bounce-debian-kernel=glddk-debian-kernel=m.gmane.org@lists.debian.org>
To: Mikhail Gusarov <dottedmag@dottedmag.net>
Content-Disposition: inline
In-Reply-To: <873bmg9sym.fsf@vertex.dottedmag.net>
Resent-Message-ID: <qk0nWB.A.irE.JVCaDB@murphy>
List-Post: <mailto:debian-kernel@lists.debian.org>
List-Help: <mailto:debian-kernel-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-kernel-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-kernel-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2005 at 11:30:09PM +0600, Mikhail Gusarov wrote:
> Hello,
> 
> I've encountered the problem with 2.6.14 kernels: they are shipped
> with ancient version of ipw2200 drivers (1.0.0 while current version
> is 1.0.7) and ancient version of ieee80211 subsystem (copyrighted as
> 2004, so also outdated).
> 
> This breaks compilation of module from ipw2200-source package (because
> it links against in-kernel ieee80211).

I assume the problem you are seeing is a headers problem.

> Is there way to modularize builds to exclude ieee80211 or just disable
> it (along with ipw2200) because it is outdated and current vesion is
> shipped in ieee80211-source package?

Probably the best place to start is to ping netdev to find out if
there are any plans to update IPW2200 in Linus's tree. I've CCed
that list, hopefully someone can shed some light on this.

-- 
Horms
