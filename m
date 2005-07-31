From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: Re: [-mm patch] include/net/ieee80211.h must #include
	<linux/wireless.h>
Date: Sat, 30 Jul 2005 19:24:22 -0700
Message-ID: <20050731022422.GH8195@jm.kir.nu>
References: <20050727195100.GA29092@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, hostap@shmoo.com,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20050727195100.GA29092@stusta.de>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://lists.shmoo.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2005 at 09:51:00PM +0200, Adrian Bunk wrote:

> gcc found an (although perhaps harmless) bug:
> 
>   CC      net/ieee80211/ieee80211_crypt.o
> In file included from net/ieee80211/ieee80211_crypt.c:21:
> include/net/ieee80211.h:26:5: warning: "WIRELESS_EXT" is not defined

> +++ linux-2.6.13-rc3-mm1-full/include/net/ieee80211.h	2005-07-22 18:38:10.000000000 +0200
> +#include <linux/wireless.h>

>  #if WIRELESS_EXT < 17
>  #define IW_QUAL_QUAL_INVALID   0x10

Wouldn't the proper fix be to just remove this backwards compatibility
code since WIRELESS_EXT is actually 18 in this tree anyway.. Is there
valid need to keep this header file compatible with older kernel
versions?

-- 
Jouni Malinen                                            PGP id EFC895FA
