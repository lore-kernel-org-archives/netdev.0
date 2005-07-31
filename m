From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [-mm patch] include/net/ieee80211.h must #include <linux/wireless.h>
Date: Sat, 30 Jul 2005 23:13:49 -0400
Message-ID: <42EC41ED.3010000@pobox.com>
References: <20050727195100.GA29092@stusta.de> <20050731022422.GH8195@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, Andrew Morton <akpm@osdl.org>,
	hostap@shmoo.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261576AbVGaDOI@vger.kernel.org>
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20050731022422.GH8195@jm.kir.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> Wouldn't the proper fix be to just remove this backwards compatibility
> code since WIRELESS_EXT is actually 18 in this tree anyway.. Is there
> valid need to keep this header file compatible with older kernel
> versions?

Nope.  Ripping out such back-compat code would be quite acceptable.

	Jeff
