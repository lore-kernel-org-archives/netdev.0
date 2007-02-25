From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [Bugme-new] [Bug 8053] New: net/ieee80211/ieee80211_crypt_tkip.c
 spams kernel message buffer
Date: Sat, 24 Feb 2007 20:55:32 -0600
Message-ID: <45E0FAA4.6000408@lwfinger.net>
References: <200702220057.l1M0vxe9012470@fire-2.osdl.org> <20070221171748.9b113f75.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, ast@domdv.de, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:50889 "EHLO
	mtiwmhc12.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933638AbXBYCzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 21:55:39 -0500
In-Reply-To: <20070221171748.9b113f75.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Wed, 21 Feb 2007 16:57:59 -0800
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=8053
>>
>>            Summary: net/ieee80211/ieee80211_crypt_tkip.c spams kernel
>>                     message buffer
>>     Kernel Version: 2.6.20.1
>>             Status: NEW
>>           Severity: high
>>              Owner: networking_wireless@kernel-bugs.osdl.org
>>          Submitter: ast@domdv.de
>>
>>
>> As sent to lkml and netdev on 2007/02/07 without any reply:
>>
>> net/ieee80211/ieee80211_crypt_tkip.c outputs tons of these which didn't
>> happen with 2.6.18.2 (only one or two of these after enabling the
>> ipw2200 with the kill switch):
>>
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e560
>> printk: 19 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e574
>> printk: 19 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e588
>> printk: 18 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e59b
>> printk: 19 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e5af
>> printk: 19 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e5c3
>> printk: 19 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e5d7
>> printk: 19 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e5eb
>> printk: 19 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e5ff
>> printk: 16 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e612
>> printk: 17 messages suppressed.
>> TKIP: replay detected: STA=00:0e:2e:94:84:c3 previous TSC 020000000000
>> received TSC 00000002e626
>>
>> Note that the AP in question is a LCS-WA5-40 running in WPA/WPA2 mixed mode and
>> that the client in uses:
>>
>> proto=RSN
>> pairwise=CCMP
>> group=TKIP
>>
> 
> How rude.  Can we please get that message killed in both 2.6.21 and
> 2.6.20.x?

With the previous TSC having that strange value (020000000000), there must be some sort of driver
and/or AP error. With the possible exception of the situation where the "previous" and "received"
TSC are the same indicating a retransmit, I feel such messages are of value and do not support
killing them.

Larry


