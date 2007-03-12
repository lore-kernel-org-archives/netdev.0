From: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Subject: Re: wireless extensions vs. 64-bit architectures
Date: Mon, 12 Mar 2007 13:34:53 -0700
Message-ID: <20070312203453.GA4230@bougret.hpl.hp.com>
References: <20070308184954.GA24485@bougret.hpl.hp.com> <1173382042.3248.63.camel@johannes.berg> <20070308193412.GG23040@devicescape.com> <1173382802.3248.68.camel@johannes.berg> <20070308221128.GA24884@bougret.hpl.hp.com> <1173393326.3831.21.camel@johannes.berg> <20070309213531.GA28070@bougret.hpl.hp.com> <1173634801.3382.8.camel@johannes.berg> <20070312175639.GA4048@bougret.hpl.hp.com> <20070312182149.GA1785@devicescape.com>
Reply-To: jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Jouni Malinen <jkm-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070312182149.GA1785-r/za7OOdgF0ztatW0fm/fQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 12, 2007 at 10:21:49AM -0800, Jouni Malinen wrote:
> On Mon, Mar 12, 2007 at 10:56:39AM -0700, Jean Tourrilhes wrote:
> 
> > > I would guess that others "use" iwlib like that too.
> > 
> > 	Which others ? The applications that process scan results can
> > be counted on your fingers. And if you count the one actively
> > developped, you can use one hand.
> 
> Quick search of SIOCGIWSCAN with Google Code Search
> (http://www.google.com/codesearch) shows quite large set of uses. Most
> of them are from various drivers, but at least some (e.g., Xsupplicant,
> waproamd) are from user space applications. I did not actually verify
> whether any of these would be affected by the 64/32-bit issue, but I
> would assume some of the apps are indeed parsing the scan results with
> internal implementation.

	Note that you will get such a list on my web page, and if you
find something not on the list, please send it to me.
	XSupplicant uses iwlib for scanning.
	waproamd has not been actively developped for the last 3 years.
	kdenetwork/KWiFiManager uses iwlib for scanning.
	Kifi uses iwlib and has not been actively developped for the
last 2 years.
	ApRadar has not been actively developped for the last 3 years.
	SuSE netapplet is no longer on the net. wifi-radar parse the
output of iwlist.
	Mandrake net_applet, from what I can gather, use wpa_supplicant.

	Ok, we are left with :
	wpa_supplicant use its own code.
	NetworkManager : partially use iwlib, use own code for scanning.

> Jouni Malinen

	Jean
