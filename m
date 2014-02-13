From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 09/28] Remove ATHEROS_AR231X
Date: Thu, 13 Feb 2014 15:14:22 -0500
Message-ID: <20140213201421.GJ22203@tuxdriver.com>
References: <1391971686-9517-1-git-send-email-richard@nod.at>
 <1391971686-9517-10-git-send-email-richard@nod.at>
 <52F7D480.1050106@hauke-m.de>
 <52F7DF21.70207@nod.at>
 <CAHNKnsS7Mv4ZhBWZa53go9L9nZimJ7_FG5HFJ9C3kkGMAEz-mA@mail.gmail.com>
 <52F8C373.9060108@rempel-privat.de>
 <CAHNKnsQF5Hdf3JT91moPraRQzn4kMpdD2NSiJ7b30wQhS1W4MA@mail.gmail.com>
 <CAGVrzcYnECx5Q=i+m6qZn29y4JALDpw5SWoUNP-S6HgPR3_ygQ@mail.gmail.com>
 <CAHNKnsRACSo=DfOyiHxqV3acv_wfZmz4tMnYAW0wo4OCibwdfA@mail.gmail.com>
 <CAHNKnsRQp7WLSJNAXEYPTd=qs1DquOfNgKtHES-Utvcy1=FEgQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>,
	Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>,
	Jonathan Bither <jonbither-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	OpenWrt Development List <openwrt-devel-ZwoEplunGu0+xA9t4nZiwti2O/JbrIOy@public.gmane.org>,
	Hauke Mehrtens <hauke-5/S+JYg5SzeELgA04lAiVw@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nick Kossifidis <mickflemm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org>,
	"open list:ATHEROS ATH5K WIR..." <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:ATHEROS ATH5K WIR..." <ath5k-devel-juf53994utBLZpfksSYvnA@public.gmane.org>,
	open-5/S+JYg5SzeELgA04lAiVw@public.gmane.org,
	"list-5/S+JYg5SzeELgA04lAiVw@public.gmane.org:NETWORKING DRIVERS" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"antonynpavlov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <antonynpavlov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
To: Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAHNKnsRQp7WLSJNAXEYPTd=qs1DquOfNgKtHES-Utvcy1=FEgQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 12, 2014 at 02:50:30PM +0400, Sergey Ryazanov wrote:
> 2014-02-11 3:43 GMT+04:00 Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> > 2014-02-11 2:37 GMT+04:00 Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>:
> >> 2014-02-10 4:38 GMT-08:00 Sergey Ryazanov <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:
> >>> 2014-02-10 16:17 GMT+04:00 Oleksij Rempel <linux-YEK0n+YFykbzxQdaRaTXBw@public.gmane.org>:
> >>>> Am 10.02.2014 13:05, schrieb Sergey Ryazanov:
> >>>>> 2014-02-10 0:03 GMT+04:00 Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>:
> >>>>>> Am 09.02.2014 20:18, schrieb Hauke Mehrtens:
> >>>>>>> On 02/09/2014 07:47 PM, Richard Weinberger wrote:
> >>>>>>>> The symbol is an orphan, get rid of it.
> >>>>>>>>
> >>>>>>>> Signed-off-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
> >>>>>>>> ---
> >>>>>>>>  drivers/net/wireless/ath/ath5k/Kconfig | 10 +++++-----
> >>>>>>>>  drivers/net/wireless/ath/ath5k/ath5k.h | 28 ----------------------------
> >>>>>>>>  drivers/net/wireless/ath/ath5k/base.c  | 14 --------------
> >>>>>>>>  drivers/net/wireless/ath/ath5k/led.c   |  7 -------
> >>>>>>>>  4 files changed, 5 insertions(+), 54 deletions(-)
> >>>>>>>>
> >>>>>>>
> >>>>>>> This code is used in OpenWrt with an out of tree arch code for the
> >>>>>>> Atheros 231x/531x SoC. [0] I do not think anyone is working on adding
> >>>>>>> this code to mainline Linux kernel, because of lack of time/interest.
> >>>>>>
> >>>>>> Sorry, we don't maintain out of tree code.
> >>>>>>
> >>>>>
> >>>>> Oleksij, Jonathan do you still working to make ar231x devices work
> >>>>> with upstream, since your posts [1, 2]? Or may be someone from OpenWRT
> >>>>> team would like to add upstream support?
> >>>>>
> >>>>> 1. https://lkml.org/lkml/2013/5/13/321
> >>>>> 2. https://lkml.org/lkml/2013/5/13/358
> >>>>>
> >>>>
> >>>> Hi,
> >>>> my current target was to provide barebox and openocd support.
> >>>> - ar2313 is already upstream on barebox.
> >>>> - ar2315-2318 (barebox) awaiting review by Anthony Pavlov.
> >>>> - openocd (EJTAG) support is ready and i'll push it ASUP.
> >>>>
> >>> WOW, Impressive.
> >>
> >> That's a nice toy project, although since there are is an existing
> >> bootloader with sources, I would have shifted the priority towards
> >> getting the kernel support merged such that the bootloader can be used
> >> for something. BTW I sent a few devices to Jonathan, not sure if he
> >> ever got those...
> >>
> >>>
> >>>> I hope Jonathan do kernel part. If not, i can provide some work, since i
> >>>> have testing boards and expiriance on this hardware.
> >>>>
> >>> If you need, I can test kernel part, or even do some porting work. I
> >>> have some AR231x based boards, e.g. Ubnt LS2 and NS2.
> >>
> >> I guess you could start splitting the OpenWrt patches into a format
> >> that makes them suitable for being merged upstream and starting with
> >> the MIPS parts. There might be a bunch of checkpatch.pl cleanup work
> >> to do before getting those submitted.
> >
> > I will do that if Jonathan does not have a working solution, which he
> > would like to push upstream. So, let's wait for his reply.
> >
> 
> John, can you delay the merging of this patch for a few months, I will
> try to prepare the necessary patches to add AR231x architecture to the
> kernel and send them to linux-mips.

OK -- looking forward to your patches.

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
