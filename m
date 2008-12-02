From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [patch for 2.6.28? 1/1] bluetooth: Dell Wireless 365 requires
 reset quirk
Date: Tue, 02 Dec 2008 01:22:19 +0100
Message-ID: <1228177339.31158.155.camel@violet.holtmann.net>
References: <200812012201.mB1M155p001654@imap1.linux-foundation.org>
	 <1228169030.31158.154.camel@violet.holtmann.net> <49347D69.7070807@tpi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mario_limonciello-8PEkshWhKlo@public.gmane.org, hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <49347D69.7070807-l6nL5VImRDY@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tim,

> >> This patch causes the BT365 to be reset when the driver is loaded. 
> >> Without it, the machine is unable to connect to other devices or to scan
> >> for devices.
> >>
> >> Signed-off-by: Mario Limonciello <mario_limonciello-8PEkshWhKlo@public.gmane.org>
> >> Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >> Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
> >> Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> >> Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> >> Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> > 
> > NAK. I fixed this differently by making the reset quirk default.
>
> Does that mean the devices in blacklist_table that have _only_
> BTUSB_RESET should be removed? It would get rid of roughly half of the
> entries.

that has already been done. See the pull request I sent to Dave.

Regards

Marcel
