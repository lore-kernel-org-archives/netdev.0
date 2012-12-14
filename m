From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 10/12] mac802154: fix destructon
 ordering for ieee802154 devices
Date: Fri, 14 Dec 2012 13:16:15 -0500 (EST)
Message-ID: <20121214.131615.1528694276738811674.davem@davemloft.net>
References: <20121214110229.11019.63713.stgit@zurg>
	<20121214110303.11019.41133.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20121214110303.11019.41133.stgit@zurg>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Date: Fri, 14 Dec 2012 15:03:03 +0400

> mutex_destroy() must be called before wpan_phy_free(), because it puts the last
> reference and frees memory. Catched as overwritten poison in kmalloc-2048.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

Applied.

------------------------------------------------------------------------------
LogMeIn Rescue: Anywhere, Anytime Remote support for IT. Free Trial
Remotely access PCs and mobile devices and provide instant support
Improve your efficiency, and focus on delivering more value-add services
Discover what IT Professionals Know. Rescue delivers
http://p.sf.net/sfu/logmein_12329d2d
