From: Jeff Williams <angelbane-GrrYUJ3DTa8@public.gmane.org>
Subject: Re: The future of the TI ACX wireless driver
Date: Sun, 10 Jun 2007 10:21:32 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0706101014520.2936@dulcinea>
References: <1d9d9b240706100735k374b5800ie64370e1e9bff1ef@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: acx100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Planella <david.planella-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1d9d9b240706100735k374b5800ie64370e1e9bff1ef-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> * Mac80211 driver, which uses the seemingly
> soon-to-be-included-in-kernel mac80211 stack, available on the
> wireless-dev tree (the stack, not the driver).
> This release is only available here [2] and needs some work before
> being included in wireless-dev, since it was released at the time when
> mac80211 was still called d80211. In any case, having had a quick look
> at the code, I believe that replacing the d80211.h header reference to
> mac80211.h and maybe refactoring some functions might be all what is
> needed for an initial compilation. Note that I haven't got any
> previous driver or kernel module development experience, so I might be
> wrong here. What would also be needed is to merge all changes from the
> softmac and plain drivers.
>
You can find a updated-as-of-last-month mac80211 pci driver at 
http://airgo.wdwconsulting.net/acx-mac80211-20070510.patch.bz2
it may or may not work, it compiles, it responds with aps to iwlist sc. 
Enabling ACX_MAC80211_USB will cause the build to fail. I'll be happy to 
take patches and bug reports.

thanks,

Jeff Williams
