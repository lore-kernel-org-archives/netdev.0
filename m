From: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 2/4] net: rfkill: gpio: remove gpio names
Date: Fri, 7 Mar 2014 10:51:27 +0800
Message-ID: <CACRpkdZo1UHyCHe20LqRefCvS9BOT-2XeQXiZzLDQzUz4=Yc-w@mail.gmail.com>
References: <1392900697-27577-1-git-send-email-heikki.krogerus@linux.intel.com>
	<1392900697-27577-3-git-send-email-heikki.krogerus@linux.intel.com>
	<53062F97.3050407@wwwdotorg.org>
	<CAGb2v66-tDZhrm9dnXe+PdQTaLZbw20sw3uYzLor2eXpVWmPMA@mail.gmail.com>
	<5306E599.7020605@wwwdotorg.org>
	<CACRpkdZBvKU31EDX=6=wVLXaQDAqD6VHtaE_mGnFLr1UYQAH9g@mail.gmail.com>
	<530CD45A.8050803@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rhyland Klein <rklein-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Mark Gross <mark.gross-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <530CD45A.8050803-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 26, 2014 at 1:35 AM, Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org> wrote:
> On 02/25/2014 02:13 AM, Linus Walleij wrote:

>> So it is basically there to satisfy the habit in some device
>> tree bindings to name gpio arrays instead of just passing gpios = <...>;
>> (The latter should be encouraged going forward.)
>
> Do you really want to switch from named GPIO lookups to index-based GPIO
> lookups?

I don't know what I want. I only know that ACPI and DT people
are starting to step on each others feet.

> Index-based lookups make it much harder to extend the DT
> binding in a backwards-compatible fashion, especially in the face of
> optional GPIOs (of which all of CD, WP, power are).

You're probably right. At the same time it makes the world complex
for the ambition to use the same interface for DT and ACPI alike.

Yours,
Linus Walleij
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
