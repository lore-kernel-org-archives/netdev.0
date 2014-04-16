From: Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/7] gpiolib: gpiolib-of: Implement device
 tree gpio-names based lookup
Date: Wed, 16 Apr 2014 16:06:59 +0900
Message-ID: <CAAVeFu+rJXH=Uat5_qWPu6OfmDAFxHj2b+n=OSmwtSw4s+fv6w@mail.gmail.com>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-2-git-send-email-wens@csie.org> <20140415142024.GD3207@lukather>
 <CAAVeFuLDhTVGDnmYtnxEY8hhn6HE6tU9OB24WDPtmxEHjiRiuQ@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	"linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <linux-sunxi+bncBDE4FPUCVULRBJ6YXCNAKGQE7LGW6WY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <CAAVeFuLDhTVGDnmYtnxEY8hhn6HE6tU9OB24WDPtmxEHjiRiuQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 3:12 PM, Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Tue, Apr 15, 2014 at 11:20 PM, Maxime Ripard
> <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org> wrote:
>> Hi Chen-Yu,
>>
>> On Tue, Apr 15, 2014 at 02:41:35PM +0800, Chen-Yu Tsai wrote:
>>> This patch provides of_get_gpiod_flags_by_name(), which looks up GPIO
>>> phandles by name only, through gpios/gpio-names, and not by index.
>>
>> IIRC, gpios only uses the *-gpios properties, and not gpios/gpio-names
>> pattern seen on various other things.
>>
>> Is it some new property you introduce? If so, please add it to the
>> documentation.
>>
>> Now, I'm not sure that having two distinct representations of GPIOs in
>> the DT is a good thing. Yes, it's looking odd compared to other
>> similar bindings, but it's what we have to deal with.
>
> Mmmm I *think* I somehow remember a discussion about this topic
> recently, but I cannot find it. Maybe Chen-yu could point us to the
> conclusion of this discussion and the rationale for (re)implementing
> named GPIOs this way?

Aha, here maybe:

https://lkml.org/lkml/2014/1/21/164

However I don't see a clear conclusion that we should implement that
scheme. Not that I am strongly against it, but I'd like to see a
practical purpose for it.
