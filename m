From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [PATCH] e100: Use pci_pme_active for clearing wake-up events and disabling PME#
Date: Tue, 9 Sep 2008 18:01:30 +0200
Message-ID: <200809091801.31732.elendil@planet.nl>
References: <200809090812.37649.elendil@planet.nl> <200809091514.23817.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jesse.brandeburg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200809091514.23817.rjw-KKrjLPT3xs0@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 September 2008, Rafael J. Wysocki wrote:
> The appended patch should fix the problem (ISTR sending it some time
> ago already).

Patch works for me.

Thanks Rafael!

> e100: Use pci_pme_active for clearing wake-up events and disabling PME#
>
> Currently e100 uses pci_enable_wake() to clear pending wake-up events
> and disable PME# during intitialization, but that function is not
> suitable for this purpose, because it immediately returns error code
> if device_may_wakeup() returns false for given device.
>
> Make e100 use pci_pme_active(), which carries out exactly the
> required operations, instead.
>
> Signed-off-by: Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org>

Tested-by: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
