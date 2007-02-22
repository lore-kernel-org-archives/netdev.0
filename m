From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8053] New:
 net/ieee80211/ieee80211_crypt_tkip.c spams kernel message buffer
Date: Wed, 21 Feb 2007 17:17:48 -0800
Message-ID: <20070221171748.9b113f75.akpm@linux-foundation.org>
References: <200702220057.l1M0vxe9012470@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, ast@domdv.de, stable@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60994 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422856AbXBVBTz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 20:19:55 -0500
In-Reply-To: <200702220057.l1M0vxe9012470@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Feb 2007 16:57:59 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8053
> 
>            Summary: net/ieee80211/ieee80211_crypt_tkip.c spams kernel
>                     message buffer
>     Kernel Version: 2.6.20.1
>             Status: NEW
>           Severity: high
>              Owner: networking_wireless@kernel-bugs.osdl.org
>          Submitter: ast@domdv.de
> 
> 
> As sent to lkml and netdev on 2007/02/07 without any reply:
> 
> net/ieee80211/ieee80211_crypt_tkip.c outputs tons of these which didn't
> happen with 2.6.18.2 (only one or two of these after enabling the
> ipw2200 with the kill switch):
> 
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e560
> printk: 19 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e574
> printk: 19 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e588
> printk: 18 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e59b
> printk: 19 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e5af
> printk: 19 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e5c3
> printk: 19 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e5d7
> printk: 19 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e5eb
> printk: 19 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e5ff
> printk: 16 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e612
> printk: 17 messages suppressed.
> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
> received TSC 00000002e626
> 
> Note that the AP in question is a LCS-WA5-40 running in WPA/WPA2 mixed mode and
> that the client in uses:
> 
> proto=RSN
> pairwise=CCMP
> group=TKIP
> 

How rude.  Can we please get that message killed in both 2.6.21 and
2.6.20.x?

