From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.17-mm2
Date: Sat, 24 Jun 2006 14:43:21 -0700
Message-ID: <20060624144321.e41cf408.akpm@osdl.org>
References: <20060624061914.202fbfb5.akpm@osdl.org>
	<200606242141.41055.dominik.karall@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:42981 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751107AbWFXVno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jun 2006 17:43:44 -0400
To: Dominik Karall <dominik.karall@gmx.net>
In-Reply-To: <200606242141.41055.dominik.karall@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 24 Jun 2006 21:41:41 +0200
Dominik Karall <dominik.karall@gmx.net> wrote:

> On Saturday, 24. June 2006 15:19, Andrew Morton wrote:
> > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1
> >7/2.6.17-mm2/
> 
> hi!
> 
> I get this warning on make modules_install:
> 
> WARNING: /lib/modules/2.6.17-mm2/kernel/net/ieee80211/ieee80211.ko 
> needs unknown symbol wireless_spy_update
> 

Someone removed the `#ifdef CONFIG_WIRELESS_EXT' from around the callsite
in net/ieee80211/ieee80211_rx.c and didn't update Kconfig appropriately.

Presumably, setting CONFIG_WIRELESS_EXT will get you going again.
