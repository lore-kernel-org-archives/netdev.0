From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCHv2 3/4] ARM: tegra: use build-in device properties with rfkill_gpio
Date: Tue, 23 Feb 2016 11:15:31 +0100
Message-ID: <5438459.Mb6Ga2Xhyq@wuerfel>
References: <1453712629-143317-1-git-send-email-heikki.krogerus@linux.intel.com> <1453797724.2759.4.camel@sipsolutions.net> <1455825889.2084.16.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Thierry Reding <thierry.reding-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-tegra-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	Marc Dietrich <marvin24-Mmb7MZpHnFY@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1455825889.2084.16.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-tegra-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thursday 18 February 2016 21:04:49 Johannes Berg wrote:
> On Tue, 2016-01-26 at 09:42 +0100, Johannes Berg wrote:
> > On Mon, 2016-01-25 at 13:18 +0100, Thierry Reding wrote:
> > >  
> > > Johannes, I assume that you'll want to take this through your tree
> > > because of the dependency? In that case:
> > > 
> > > Acked-by: Thierry Reding <treding-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>
> > 
> > I can, but I don't really care - perhaps you'd rather take the entire
> > series through your tree to get it into one place for Marc?
> > 
> > In which case, you have my
> > 
> > Acked-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> > 
> > for the other 3 patches.
> > 
> > Let me know which you prefer.
> > 
> Did these patches get applied anywhere? Otherwise I'm willing to pick
> them up.
> 

Fine with me too:

Acked-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Just for my curiosity: what is the difference between a rfkill-gpio
device and a gpio-keys device with a KEY_RFKILL code?

arch/arm/boot/dts/bcm4708-netgear-r6250.dts and others seem to
do the second approach in DT so they don't need to create the
platform device.

	Arnd
