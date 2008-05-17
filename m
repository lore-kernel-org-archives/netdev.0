From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Sat, 17 May 2008 15:45:04 +0200
Message-ID: <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org>
References: <1211026337.3827.25.camel@johannes.berg>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jean Tourrilhes <jt@hpl.hp.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:51437 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbYEQNpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 09:45:11 -0400
In-Reply-To: <1211026337.3827.25.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johannes,

> The /sys/class/net/*/wireless/ direcory is, as far as I know, not
> used by anyone. Additionally, the same data is available via wext
> ioctls. Hence the sysfs files are pretty much useless. This patch
> makes them optional and schedules them for removal.

it is used by HAL to classify WiFi network cards as net.80211 instead  
of net.80203 and so we do have an actual user. However HAL only tests  
for the existence of the directory wireless/.

Please fix HAL first before submitting such a patch.

Regards

Marcel

