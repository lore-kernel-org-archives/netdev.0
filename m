From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/4] Net: mac80211, remove bitfields from struct	ieee80211_txrx_data
Date: Mon, 13 Aug 2007 22:01:34 +0200
Message-ID: <46C0B89E.3080505@gmail.com>
References: <2653412025907217317@wsc.cz> <1187009078.27916.109.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jbenc-AlSwsSmVLrQ@public.gmane.org, flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1187009078.27916.109.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg napsal(a):
> On Sun, 2007-08-12 at 15:08 +0200, Jiri Slaby wrote:
> 
>> -	unsigned int fragmented:1; /* whether the MSDU was fragmented */
>> +	/* whether the MSDU was fragmented */
>> +#define IEEE80211_TXRXD_FRAGMENTED		BIT(0)
>> +#define IEEE80211_TXRXD_TXUNICAST		BIT(1)
>> +#define IEEE80211_TXRXD_TXPS_BUFFERED		BIT(2)
>> +#define IEEE80211_TXRXD_TXPROBE_LAST_FRAG	BIT(3)
>> +#define IEEE80211_TXRXD_RXIN_SCAN		BIT(4)
> 
> I know this isn't the style currently used, but could you put these
> definitions before the struct declaration? That way, kerneldoc doesn't
> totally screw up.

OK

-- 
Jiri Slaby (jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org)
Faculty of Informatics, Masaryk University
