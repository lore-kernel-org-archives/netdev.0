From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/1] linux-wireless: Added psk in struct
 cfg80211_connect_params needed for offloading 4way handshake to driver
Date: Tue, 11 Nov 2014 10:29:21 +0100
Message-ID: <1415698161.2163.0.camel@sipsolutions.net>
References: <DF163EE1A432BF4BBE6B2088220663A67437BD@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Jithu Jance <jithu-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Sreenath S <sreenats-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: "Gautam (Gautam Kumar) Shukla" <gautams-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <DF163EE1A432BF4BBE6B2088220663A67437BD-HXj2mutaA2pmqaqore1TH5r/X4hKkxxPpWgKQ6/u3Fg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-11-11 at 05:56 +0000, Gautam (Gautam Kumar) Shukla wrote:
> For offloading 4 way handshake to driver, currently we don't have any
> member  of struct cfg80211_connect_params to pass PSK from supplicant
> to driver. I have added psk for the same and added rest of the code
> needed in nl80211.h and nl80211.c to parse and make it available to
> driver.
> From supplicant, we already have psk member field in assoc_params to
> use .
> 
> Tested on x86 linux.

Your commit message needs serious work.

Also, there's a competing approach from QCA that's far more suited.

In either case though, I'm going to ask which driver is going to use
this and when it's going to land in mainline.

johannes
