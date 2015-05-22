From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [RESEND][PATCH] Bluetooth: Make request workqueue freezable
Date: Fri, 22 May 2015 13:30:13 +0200
Message-ID: <1432294213.8255.3.camel@suse.com>
References: <33C25745-6839-4858-9A3E-19EC6408ECED@holtmann.org>
		<Pine.LNX.4.44L0.1505211112310.1397-100000@iolanthe.rowland.org>
		<s5hsiaq3pv4.wl-tiwai@suse.de>	<555E158D.4090607@broadcom.com>
	 <s5hmw0x4z12.wl-tiwai@suse.de> <555E442A.808@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Takashi Iwai <tiwai-l3A5Bk7waGM@public.gmane.org>, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Laura Abbott <labbott-rxtnV0ftBwyoClj4AeEUq9i2O/JbrIOy@public.gmane.org>,
	JohanHedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Laura Abbott <labbott-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	"bluez mailin list (linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	USB list <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <555E442A.808-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-05-21 at 22:46 +0200, Arend van Spriel wrote:
> On 05/21/15 19:32, Takashi Iwai wrote:


> >>>>> Well, if the probe requires the access to a user-space file, it can't
> >>>>> be done during resume.  That's the very problem we're seeing now.
> >>>>> The firmware loader can't help much alone if it's a new device
> >>>>> object.
> 
> So you are saying each device driver should come up with some retry 
> mechanism. Would make more sense to come up with something like that 
> behind the scenes in the firmware loader so all device drivers can rely 
> on one and the same solution.

There is already a notifier for this. I don't see why the firmware
layer couldn't retrigger a match for all unbound devices, just like
we do when a new driver is loaded.

	Regards
		Oliver
