From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/2] wireless: ath9k_htc: fix NULL-deref at probe
Date: Mon, 3 Apr 2017 15:16:16 +0200
Message-ID: <20170403131616.GA3119@localhost>
References: <20170313124421.28587-1-johan@kernel.org>
 <20170403084213.GE25742@localhost>
 <87shlpomvx.fsf@kamboji.qca.qualcomm.com>
 <87k271myos.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        ath9k-devel <ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
        Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
        Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>,
        "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sujith Manoharan <Sujith.Manoharan-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87k271myos.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 03, 2017 at 01:02:28PM +0000, Kalle Valo wrote:
> Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org> writes:
> 
> > Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> writes:
> >
> >> On Mon, Mar 13, 2017 at 01:44:20PM +0100, Johan Hovold wrote:
> >>> Make sure to check the number of endpoints to avoid dereferencing a
> >>> NULL-pointer or accessing memory beyond the endpoint array should a
> >>> malicious device lack the expected endpoints.
> >>> 
> >>> Fixes: 36bcce430657 ("ath9k_htc: Handle storage devices")
> >>> Cc: Sujith Manoharan <Sujith.Manoharan-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
> >>> Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> >>
> >> Is this one still in your queue, Kalle?
> >
> > Yes, I'm just lacking behing:
> >
> > https://patchwork.kernel.org/patch/9620723/
> 
> Meant "lagging" of course. Mondays..
> 
> >> As I mentioned earlier, I should have added a
> >>
> >> Cc: stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>     # 2.6.39
> >>
> >> but left it out as I mistakingly thought the net recommendations to do
> >> so applied also to wireless.
> >
> > Ok, I'll add that.
> 
> But is 2.6.39 really correct? Shouldn't it be 2.6.39+ so that it means
> all versions since 2.6.39?

Either way is fine, the stable maintainers apply them to all later
versions.

I notice now that adding a plus sign is more common, but it's still a
1:2 ratio judging from quick grep, while the stable-kernel-rules.rst
actually uses a minus sign...

Thanks,
Johan
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
