From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: Prism54 WPA Support - wpa_supplicant - Linux general wpa support
Date: Thu, 3 Jun 2004 10:07:45 -0700
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040603170745.GD8770@bougret.hpl.hp.com>
References: <20040602071449.GJ10723@ruslug.rutgers.edu>
	<20040602132313.GB7341@jm.kir.nu> <40BEA3CB.60908@pobox.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@oss.sgi.com>, Jouni Malinen <jkmaline@cc.hut.fi>,
	hostap@shmoo.com, "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	prism54-devel@prism54.org
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40BEA3CB.60908@pobox.com>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Thu, Jun 03, 2004 at 12:06:35AM -0400, Jeff Garzik wrote:
> 
> One of the things that is nice about wireless-2.6 is that is affords the 
> opportunity to totally rethink the wireless extensions.
> 
> Although a lot of people would howl, since HostAP is essentially new 
> code from the mainline kernel perspective, a new userland API (and new 
> or updated tools) could come along with it.
> 
> I have mentioned in the past (no offense Jean!) that I do not like the 
> overly-generic wireless handler structure.  It is less type-safe than is 
> generally preferred in Linux, IMO.
> 
> A low-level wireless driver should not implement ioctls, it should 
> implement callbacks in some sort of 'struct wireless_operations' as is 
> done in other kernel subsystems.
> 
> ioctl details should be hidden from low-level drivers as much as 
> possible, through type-safe interfaces.  Strive to make both the 
> wireless driver API and the wireless userland API easy to change and 
> evolve over time.
> 
> 	Jeff

	Jeff, I'm amazed that you are so obsessed with this. Yes,
Wireless Extension could be improved in millions ways, but at least
it's working, whereas there are so many other areas where we have
nothing at all. If you talk with most people developping wireless
drivers, this doesn't even make their list. But I guess every one of
us need to have his hot topic ;-)

	I believe most people are concerned about :
	o WPA support (and security API in general)
	o SNAP encapsulation/decapsualtion in kernel
	o handling 802.11 frames natively in kernel
	o handling 802.11 management in kernel (association/deassociation, ...)

	Personally, those are my priorities :
	o getting more wireless drivers in the kernel
	o RtNetlink API for Wireless Extensions

	I also explained you how you could wrap around Wireless
Extension trivially to introduce a new driver API without breaking the
many user space tools, so that you can implement your proposal with
maximum backward compatibility. Just because there is one aspect of
the API you don't like, we don't need to throw away the good parts.

	Have fun...

	Jean
