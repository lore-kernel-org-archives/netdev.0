From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Prism54 WPA Support - wpa_supplicant - Linux general wpa support
Date: Wed, 2 Jun 2004 06:23:14 -0700
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040602132313.GB7341@jm.kir.nu>
References: <20040602071449.GJ10723@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>,
	Jean Tourrilhes <jt@bougret.hpl.hp.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>, hostap@shmoo.com,
	prism54-devel@prism54.org
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
Content-Disposition: inline
In-Reply-To: <20040602071449.GJ10723@ruslug.rutgers.edu>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 02, 2004 at 03:14:49AM -0400, Luis R. Rodriguez wrote:

> I'm glad wpa_supplicant exists :). Interacting with it *is* our missing
> link to getting full WPA support (great job Jouni). In wpa_supplicant 
> cvs I see a base code for driver_prism54.c (empty routines, just providing skeleton).
> Well I'll be diving in it now and see where I can get. If anyone else is
> interested in helping with WPA support for prism54, working with
> wpa_supplicant is the way to go.

I have a bit more code for this in my work directory somewhere (setting
the WPA IE and a new ioctl for this for the driver). I did not submit
these yet since the extended MLME mode was not working and the changes
were not yet really working properly. I can try to find these patches
somewhere.. Anyway, I would first like to see the extended MLME mode
working with any (even plaintext) AP and then somehow add the WPA IE to
the AssocReq. After that, it should be only TKIP/CCMP key configuration
and that's about it..

> I'm curious though -- wpa_supplicant is pretty much userspace. This was
> done with good intentions from what I read but before we get dirty 
> with wpa_supplicant I'm wondering if we should just integrate a lot of 
> wpa_supplicant into kernel space (specifically wireless tools).

Why? Which functionality would you like to move into kernel? Not that
I'm against moving some parts, but I would certainly like to hear good
reasons whenever moving something to kernel space if it can be done (or
in this case, has already been done) in user space..

> Regardless, as Jouni points out, there is still a framework for WPA that needs
> to be written for all linux wireless drivers, whether it's to assist
> wpa_supplicant framework or to integrate wpa_supplicant into kernel space.

The first thing I would like to see is an addition to  Linux wireless
extensions for WPA/WPA2 so that we can get rid of the private ioctls in
the drivers. Even though these can often be similar, it would be nice to
just write one driver interface code in wpa_supplicant and have it
working with all Linu drivers.. I hope to find some time to write a
proposal for this.

-- 
Jouni Malinen                                            PGP id EFC895FA
