From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: Prism54 WPA Support - wpa_supplicant - Linux general wpa support
Date: Wed, 2 Jun 2004 18:40:00 -0700
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <20040603014000.GA7548@jm.kir.nu>
References: <20040602071449.GJ10723@ruslug.rutgers.edu>
	<20040602132313.GB7341@jm.kir.nu>
	<20040602155542.GC24822@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Netdev <netdev@oss.sgi.com>, hostap@shmoo.com,
	prism54-devel@prism54.org, Jeff Garzik <jgarzik@pobox.com>,
	Jean Tourrilhes <jt@bougret.hpl.hp.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20040602155542.GC24822@ruslug.rutgers.edu>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 02, 2004 at 11:55:42AM -0400, Luis R. Rodriguez wrote:

> If you find the patches that'd be great :). I'll see what I can do about
> fixing up extended MLME. I'll keep you posted. 

I now know where the wpa_supplicant part is and once I find the matching
patch for Prism54 driver, I'll send them both to you.

> I have yet to review most of the wpa_supplicant code so I cannot say for
> sure yet what I think should go into the kernel. I e-mailed most lists
> mainly to get comments from others who have poked at wpa_supplicant
> and/or are looking into adding WPA client support into their drivers.
> I just wanted to make sure we were heading in the right direction since
> I only see 2 drivers that are currently using wpa_supplicant.

You may have seen only two drivers, but actually I'm already aware of at
least seven drivers that work with wpa_supplicant.. All of these are not
yet available publicly, though.

I believe that the current design for wpa_supplicant is quite alright
for most cases. I would like to give some more thought for the roaming
part (i.e., consider giving more control for the driver), but this
should be doable in a backward compatible way without breaking support
with existing code.

-- 
Jouni Malinen                                            PGP id EFC895FA
