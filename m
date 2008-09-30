From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Can't build net-next-2.6 without CONFIG_MAC80211_MESH
Date: Tue, 30 Sep 2008 10:43:22 -0400
Message-ID: <20080930144322.GC3386@tuxdriver.com>
References: <48E2394A.3010707@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40433 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbYI3OoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 10:44:02 -0400
Content-Disposition: inline
In-Reply-To: <48E2394A.3010707@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2008 at 10:35:54AM -0400, Brian Haley wrote:
> Sorry if this has been discussed/fixed already, but I just noticed last  
> night I couldn't build net-next-2.6:
>
> Kernel: arch/x86/boot/bzImage is ready  (#71)
> ERROR: "mpp_path_lookup" [net/mac80211/mac80211.ko] undefined!
> ERROR: "mpp_path_add" [net/mac80211/mac80211.ko] undefined!
>
> These are defined in net/mac80211/mesh_pathtbl.c, but being called from  
> rx.c and tx.c, but I'm not building the mesh files:
>
> --> grep CONFIG_MAC80211 .config
> CONFIG_MAC80211=m
> CONFIG_MAC80211_RC_PID=y
> CONFIG_MAC80211_RC_DEFAULT_PID=y
> CONFIG_MAC80211_RC_DEFAULT="pid"
> # CONFIG_MAC80211_MESH is not set
> # CONFIG_MAC80211_LEDS is not set
> # CONFIG_MAC80211_DEBUGFS is not set
> # CONFIG_MAC80211_DEBUG_MENU is not set
>
> make oldconfig didn't make any changes, so I think the config is valid.

I have the fix queued in wireless-testing -- I think/thought Dave
is/was traveling, so I didn't rush to push it to net-next-2.6.
I'll get that pull request assembled today.  In the meantime, just
enable CONFIG_MAC80211_MESH.

Thanks,

John
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
