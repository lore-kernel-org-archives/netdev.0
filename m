From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates
 [mac80211]
Date: Fri, 29 Jan 2016 10:54:40 -0600
Message-ID: <56AB9950.5080800@lwfinger.net>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
 <1453983185.2217.12.camel@sipsolutions.net>
 <CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
 <1454013625.2332.9.camel@sipsolutions.net>
 <CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
 <CA+55aFzF0gWfvmE+6ZcHmjnO4xp-oVAQ5SWxYJhOzns2ocgCsw@mail.gmail.com>
 <1454019155.2332.15.camel@sipsolutions.net>
 <CA+55aFxjpdepHYD_6uU48kW38Z9bmf2wwA8yPZt4ibhkofmfQA@mail.gmail.com>
 <56AAC66C.1080800@lwfinger.net> <1454056380.3369.2.camel@sipsolutions.net>
 <CAP71bdVZzUUNwP3py_m1pwU21qMKth=0BmMfLuUb7=B-1840zg@mail.gmail.com>
 <1454084146.2800.0.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Kalle Valo <kvalo@codeaurora.org>,
	David Miller <davem@davemloft.net>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:35679 "EHLO
	mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272AbcA2Qyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 11:54:43 -0500
In-Reply-To: <1454084146.2800.0.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2016 10:15 AM, Johannes Berg wrote:
> On Fri, 2016-01-29 at 10:12 -0600, Larry Finger wrote:
>>
>> Upon further inspection, my log has the line "rtl8821ae 0000:02:00.0
>> wlp2s0: disabling HT/VHT due to WEP/TKIP use". I need to fix that
>> first.
>>
> Likely TKIP; enable only WPA2 (CCMP) on the AP.

I found and fixed it. The AP was using only 20 MHz channels, but now is 
configured for 20/40/80. That duplicates the warning for me and the lack of 
throughput even though it associates and authenticates.

Larry
