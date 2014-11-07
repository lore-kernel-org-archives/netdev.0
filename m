From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 3/3 3.18] rtlwifi: rtl8192se: Fix connection problems
Date: Fri, 7 Nov 2014 10:19:08 -0500
Message-ID: <20141107151908.GB29733@tuxdriver.com>
References: <1415236254-12274-1-git-send-email-Larry.Finger@lwfinger.net>
 <1415236254-12274-4-git-send-email-Larry.Finger@lwfinger.net>
 <20141106204549.GD4440@tuxdriver.com>
 <545BFA52.6000309@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <545BFA52.6000309-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2014 at 04:46:42PM -0600, Larry Finger wrote:
> On 11/06/2014 02:45 PM, John W. Linville wrote:
> >On Wed, Nov 05, 2014 at 07:10:54PM -0600, Larry Finger wrote:
> >>Changes in the vendor driver were added to rtlwifi, but some updates
> >>to rtl8192se were missed.
> >>
> >>Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> >>---
> >>  drivers/net/wireless/rtlwifi/rtl8192se/hw.c  | 129 +++++++++++++--------------
> >>  drivers/net/wireless/rtlwifi/rtl8192se/phy.c |   8 +-
> >>  drivers/net/wireless/rtlwifi/rtl8192se/sw.c  |   4 +
> >>  drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  23 +++++
> >>  drivers/net/wireless/rtlwifi/rtl8192se/trx.h |   4 +
> >>  5 files changed, 100 insertions(+), 68 deletions(-)
> >
> >This looks a bit big for a fix.  Could this be broken-up a bit more?
> >Perhaps you could enhance the changelog a bit more?
> 
> I had used a scatter-gun approach to finding the missing parts, and I did
> not take the time to see which changes were crucial, and which were not.
> 
> Now that I knew what it took, I was able to eliminate a lot of the patch
> that can be deferred for 3.19.
> 
> The commit message and the changelog for the new version are
> 
> Changes in the vendor driver were added to rtlwifi, but some updates
> to rtl8192se were missed, and the driver could neither scan nor connect.
> There are other changes that will enhance performance, but this minimal
> set fixes the basic functionality.
> 
>  drivers/net/wireless/rtlwifi/pci.c           |  3 ++-
>  drivers/net/wireless/rtlwifi/rtl8192se/hw.c  |  7 +++++--
>  drivers/net/wireless/rtlwifi/rtl8192se/phy.c |  2 ++
>  drivers/net/wireless/rtlwifi/rtl8192se/sw.c  | 16 ++++++++++++++++
>  4 files changed, 25 insertions(+), 3 deletions(-)
> 
> Will that be OK? I need to do more testing, but V2 of the patch should be
> ready for submission by tomorrow.

That sounds better, at least. :-)  Thanks, Larry!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
