From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH 4/8] net/mlx4_en: Set max rate-limit for a TC
Date: Wed, 14 Mar 2012 12:42:43 +0200
Message-ID: <4F607623.9060904@mellanox.com>
References: <1331659323-12904-1-git-send-email-amirv@mellanox.com> <1331659323-12904-5-git-send-email-amirv@mellanox.com> <CAA93jw425JDVJODhPok8WWNu6ngxGCGAX9ekp6fn8QiA5gq3zA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog116.obsmtp.com ([207.126.144.141]:51376 "HELO
	eu1sys200aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753746Ab2CNKmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 06:42:54 -0400
In-Reply-To: <CAA93jw425JDVJODhPok8WWNu6ngxGCGAX9ekp6fn8QiA5gq3zA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2012 09:16 PM, Dave Taht wrote:
> On Tue, Mar 13, 2012 at 10:21 AM, Amir Vadai<amirv@mellanox.com>  wrote:
>> From: Amir Vadai<amirv@mellanox.co.il>
>>
>> Set max rate-limit using sysfs file /sys/class/net/<interface>/qos/ratelimit
>>
>> To set, enter a space separated list of values in units of 100Mbps.  For
>> example to set ratelimit of 5G to TC0 and 10G for the reset on eth2 issue:
>> echo 50 100 100 100 100 100 100 100 100>  /sys/class/net/eth2/qos/ratelimit
>
> At least in my world, rates go down as low as 128k.
>
> If this 'qos' sys value is intended to be a generic mechanism to be
> used instead of (say) htb,
> for more than one type of ethernet device.... I would argue that the
> units need to be specified.
>
> Similarly what else is intended to live below the 'qos' subdir?

This sys value is specific to our driver, and will be shown only on 
mlx4_en netdev's.

We're open to suggestions to make it a generic sysfs entry. If it will 
really be generic, we will sure have well known units (for example KB) 
and we'll do the translation in our driver.

Thanks,
Amir
