From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ieee80211_rx_any: filter out packets, call ieee80211_rx
 or ieee80211_rx_mgt
Date: Sun, 22 Jan 2006 14:32:03 +0100
Message-ID: <43D38953.7040100@trash.net>
References: <20060118200616.GC6583@tuxdriver.com> <200601221404.52757.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jbenc@suse.cz, softmac-dev@sipsolutions.net,
	bcm43xx-dev@lists.berlios.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751247AbWAVNdE@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: <200601221404.52757.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis Vlasenko wrote:
> bcm43xx_rx() contains code to filter out packets from
> foreign BSSes and decide whether to call ieee80211_rx
> or ieee80211_rx_mgt. This is not bcm specific.
> 
> +/* Kernel doesn't have it, why? */
> +static inline int is_mcast_or_bcast_ether_addr(const u8 *addr)
> +{
> +        return (0x01 & addr[0]);
> +}

The same function exists in include/linux/etherdevice.h:

static inline int is_multicast_ether_addr(const u8 *addr)
{
        return (0x01 & addr[0]);
}
