From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 4/5] mac80211: Add more ethtools stats: survey, rates,
 etc
Date: Thu, 12 Apr 2012 09:51:52 -0700
Message-ID: <4F870828.4020708@candelatech.com>
References: <1334248375-22967-1-git-send-email-greearb@candelatech.com> <1334248375-22967-5-git-send-email-greearb@candelatech.com> <4F8705E3.2010902@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59077 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab2DLQvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 12:51:55 -0400
In-Reply-To: <4F8705E3.2010902@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/2012 09:42 AM, Florian Fainelli wrote:
> Hi,
>
> Le 04/12/12 18:32, greearb@candelatech.com a =C3=A9crit :
>> From: Ben Greear<greearb@candelatech.com>
>>
>> The signal and noise are forced to be positive since ethtool
>> deals in unsigned 64-bit values and this number should be human
>> readable. This gives easy access to some of the data formerly
>> exposed in the deprecated /proc/net/wireless file.
>
> Uh, that's misleading, the signal and noise values are typically nega=
tive, so one needs to think about mentally adding a minus sign if he/sh=
e wants to
> understand it. Does not ethtool know about 32-bits signed integers?

Ethtool stats only supports u64.  I think it's easy enough for
humans or programs to add the negative sign.  Can signal or noise
ever be > 0?  If so, that could actually break something that depends
on flipping the value to negative....

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
