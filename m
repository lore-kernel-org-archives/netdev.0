From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] Merge the Sonics Silicon Backplane subsystem
Date: Fri, 27 Jul 2007 21:39:45 +0200
Message-ID: <200707272139.45629.mb@bu3sch.de>
References: <200707271857.24162.mb@bu3sch.de> <20070727192120.GB7572@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	Gary Zambrano <zambrano@broadcom.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:45833
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbXG0Tlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2007 15:41:32 -0400
In-Reply-To: <20070727192120.GB7572@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 27 July 2007 21:21:20 John W. Linville wrote:
> On Fri, Jul 27, 2007 at 06:57:20PM +0200, Michael Buesch wrote:
> > The Sonics Silicon Backplane is a mini-bus used on
> > various Broadcom chips and embedded devices.
> > Devices using the SSB include b44, bcm43xx and various
> > Broadcom based wireless routers.
> > A b44 and bcm43xx port and a SSB based OHCI driver is available.
> > 
> > Signed-off-by: Michael Buesch <mb@bu3sch.de>
> 
> At first glance it looks like there might be some tab/space issues
> in some of the #define blocks toward the end of the patch, although
> those might be intentional.

They are intentional. It's something like this:

#define SSB_REGISTER_XX			0xF88
#define  SSB_VALUE_FOR_REGISTER_XX	0x0001
#define  SSB_MASK_FOR_REGISTER_XX	0xFF00
#define SSB_REGISTER_YY			0xF99
...

> Aside from whatever other style issues that might be identified, I'll
> state that this code has been carried in wireless-dev for months and
> thereby also spent a lot of time in -mm as well as Fedora (rawhide
> and F-7).  The code has proven to be reasonably stable and reliable.

And it's in the OpenWRT trunk since quite some time.

-- 
Greetings Michael.
