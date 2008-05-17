From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Sat, 17 May 2008 16:36:31 +0200
Message-ID: <31B1A5D6-8E8B-4148-860F-326FEEE5A3EE@holtmann.org>
References: <1211026337.3827.25.camel@johannes.berg> <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org> (sfid-20080517_154639_384202_6D3479C2) <1211032475.6252.2.camel@johannes.berg>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jean Tourrilhes <jt@hpl.hp.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756176AbYEQOgr@vger.kernel.org>
In-Reply-To: <1211032475.6252.2.camel@johannes.berg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Johannes,

>>> The /sys/class/net/*/wireless/ direcory is, as far as I know, not
>>> used by anyone. Additionally, the same data is available via wext
>>> ioctls. Hence the sysfs files are pretty much useless. This patch
>>> makes them optional and schedules them for removal.
>>
>> it is used by HAL to classify WiFi network cards as net.80211 instead
>> of net.80203 and so we do have an actual user. However HAL only tests
>> for the existence of the directory wireless/.
>
> Oh, ok, I didn't know that, thanks.
>
>> Please fix HAL first before submitting such a patch.
>
> Sure, I'll take a look at that.

saw your patch. Looks good to me. However what do we do with the non- 
mac80211 drivers that are using WEXT directly. These should be  
detected as net.80211, too.

Regards

Marcel
