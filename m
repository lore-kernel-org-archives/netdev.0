From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Thu, 20 Sep 2007 15:28:04 +0100
Message-ID: <46F28374.9040106@gentoo.org>
References: <20070919181005.GB5483@tuxdriver.com> <46F19DD0.2050605@gentoo.org> <20070920134730.GC6748@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070920134730.GC6748-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> I know that you will argue that a rename is unnecessary if we
> simply port the existing driver to mac80211, which is certainly true.
> I just wonder if that is the least bumpy solution for users.  At least
> with a new driver, if something doesn't work then the old driver is
> still there as a fallback.  Plus you can avoid some confusion with
> old howtos and such on the web referring to an old driver instead
> of the new one, etc.  Maybe that isn't a huge issue in this case,
> but I wouldn't underestimate the possible confusion.

Maybe I'll provide a one-off externally building driver for 2.6.25 or 
something like that, just as a basis for comparison. I think biting the 
bullet and simply attacking the issues that come up is the best way.

Old documentation will still be relevant for the mac80211 driver, 
especially if we don't change the driver/config names -- offhand I can't 
think of any obvious differences between the user interface to the 2 
drivers.

>> (just to clarify to others: this is the first I heard of this merge 
>> before John posted it).
> 
> Yes, sorry...permission, forgiveness...forgive? :-)

Of course :)

> If you are determined not to have it in 2.6.24 then I will relent.
> I will also suggest that Larry start sending any softmac bugs to
> you... :-)

That's fine.

> If we will be having a port rather than a new driver, how soon after
> 2.6.24-rc1 closes can we queue the port for 2.6.25?  I think it
> should be almost immediately, to ensure maximum test exposure and to
> "seal the deal".  What do you think?

I think that's realistic, I'll do what I can.

Thanks,
Daniel
