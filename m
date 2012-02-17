From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] Cleaning up code formatting errors in net/wireless pointed out by checkpatch.
Date: Fri, 17 Feb 2012 15:47:36 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E75@saturn3.aculab.com>
References: <1329492603-3972-1-git-send-email-lfelipe@profusion.mobi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <johannes@sipsolutions.net>, <davem@davemloft.net>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Luis Felipe Strano Moraes" <lfelipe@profusion.mobi>,
	<linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1329492603-3972-1-git-send-email-lfelipe@profusion.mobi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
> These are mostly minor changes and they are being sent as one 
> patch only in order to cause the smallest amount of disruption.

A lot of these changes don't seem to match what I thought the
linux kernel code style is.

eg:
>  void cfg80211_bss_age(struct cfg80211_registered_device *dev,
> -                      unsigned long age_secs);
> +		      unsigned long age_secs);
Args no longer lined up.

> -		pos = (u8 *) & hdr->addr4;
> +		pos = (u8 *) &hdr->addr4;
no space after cast?

> -	p1 = (u8*)(ht_capa);
> +	p1 = (u8 *)(ht_capa);
Still extra ().

I'm also not sure (personally) this sort of churn is useful.

	David
