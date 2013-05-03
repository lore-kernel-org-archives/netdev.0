From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: Re: tg3 adapter losing link - PM related?
Date: Fri, 3 May 2013 11:48:22 -0700
Message-ID: <51840676.5000004@broadcom.com>
References: <20130503092846.GA5126@pcnci.linuxbox.cz>
 <5183D40B.8090605@broadcom.com>
 <1367606390.2756.6.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Nikola Ciprich" <nikola.ciprich@linuxbox.cz>,
	netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3392 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762990Ab3ECSsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 14:48:31 -0400
In-Reply-To: <1367606390.2756.6.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/03/2013 11:39 AM, Ben Hutchings wrote:
> On Fri, 2013-05-03 at 08:13 -0700, Nithin Nayak Sujir wrote:
>> Hi Nikola,
>> 1. What device is present on this server? Can you give the tg3 messages
>> in /var/log/messages? Can you also give the output of "ethtool -i <iface>"?
>>
>> 2. Is it possible for you to try the latest 3.9 upstream kernel?
>>
>> 3. Any reason why the link is at 100Mb? The switch does not support gig?
>> What switch is it?
>>
>> 4. I don't think you can turn off EEE in the bios, but you can try
>> turning autoneg off. Try "ethtool -s <iface> speed 100 duplex full
>> autoneg off". It's not exactly the same thing since the device still has
>> EEE enabled but not negotiated.
> [...]
>
> It should be possible to disable EEE with ethtool.  You really should
> implement the EEE configuration operations in tg3 if you're going to
> enable it at all.
>

I agree. I plan to have a patch when netdev opens.

> Ben.
>
