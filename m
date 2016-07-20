From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Wed, 20 Jul 2016 17:48:23 +0200
Message-ID: <3717687.FpcDfXaOEr@debian64>
References: <74d0fd1d-8197-1e4a-1ab1-a879d6dcea4e@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"driverdev-devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org"
	<driverdev-devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org>,
	Jes Sorensen <Jes.Sorensen-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
To: Xose Vazquez Perez <xose.vazquez-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <74d0fd1d-8197-1e4a-1ab1-a879d6dcea4e-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday, July 20, 2016 5:06:27 PM CEST Xose Vazquez Perez wrote:
> Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> 
> > rtlwifi, but I found the older r8712u device to work fine with
> > the staging/rtl8712 driver.
> 
> A replacement for "staging/rtl8712", with MAC80211 support, is
> available at: https://github.com/chunkeey/rtl8192su
> 
> Also a fullmac/cfg80211 driver(r92su) is available at the
> same repository.
> 
Yes, it has its problems. The rtl8712/r92su isn't really
a fullmac device. While the MLME (scan, probe, auth, assoc) is
done by the firmware. The 802.11 frame creation (from 802.3)
frames needs to be done by the driver. The rtl8712 firmware
however has its fair share of issues. Like: no support for
(tx) fragmentation and ERP is a mystery too. monitor 
mode is barely working and limited to 20Mhz wide channels.
There's also limited tx injection support.... and of course
stability issues (just like with the staging/rtl8712 driver
or FreeBSD's rsu driver).

The rtl8192su driver (based on rtlwifi) in the same repository
has proper fragmentation support. But it uses the firmware from
the windows/mac os x driver, which is similar to rtl8192se softmac
firmware in design. Getting it to work properly in station mode
however either needs "some magic" or help from Realtek's USB group...


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
