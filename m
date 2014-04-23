From: Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/7] gpiolib: gpiolib-of: Implement device
 tree gpio-names based lookup
Date: Wed, 23 Apr 2014 10:49:12 +0900
Message-ID: <CAAVeFuL7B7kVw7ME=Vo_snhG27aBphKO8Uzvzen1gyD=R2ETNA@mail.gmail.com>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-2-git-send-email-wens@csie.org> <CACRpkdZDjC1KxM2yJqsgpg2MxBamX1EObsuahB-2c+ShuBXm8A@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>, Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>,
	"linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-sunxi+bncBDE4FPUCVULRBLFY3SNAKGQETP55HCA-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <CACRpkdZDjC1KxM2yJqsgpg2MxBamX1EObsuahB-2c+ShuBXm8A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Wed, Apr 23, 2014 at 12:02 AM, Linus Walleij
<linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> wrote:
> On Tue, Apr 15, 2014 at 8:41 AM, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org> wrote:
>
>> This patch provides of_get_gpiod_flags_by_name(), which looks up GPIO
>> phandles by name only, through gpios/gpio-names, and not by index.
>>
>> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>
> Like Alexandre I have no strong opinion on this alternative scheme.

Yeah this new lookup scheme probably does no harm, but I think it
should be a little bit more motivated as it is, after all, introducing
more potential confusion for DT users.

It does not look like this new lookup scheme is necessary to Chen-Yu's
patchset and that he could as well have used the current one. Right
now there is only one way to define GPIOs - if we introduce a second
one, then which one should new DT users choose? Which one looks
better? I can already endless fights taking place over this.

Does this new lookup help with some of the existing problems we have
like ACPI/DT lookup compatibility?

I just need to be given one practical reason to give my ack.

Alex.
