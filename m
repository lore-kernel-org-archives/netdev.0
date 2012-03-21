From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH V1 4/6] net/mlx4_en: Set max rate-limit for a TC
Date: Wed, 21 Mar 2012 15:43:11 +0200
Message-ID: <4F69DAEF.5010407@mellanox.com>
References: <1332321903-11704-1-git-send-email-amirv@mellanox.com>  <1332321903-11704-5-git-send-email-amirv@mellanox.com> <1332324776.25742.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Roland Dreier <roland@purestorage.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:40069 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755498Ab2CUNpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 09:45:12 -0400
In-Reply-To: <1332324776.25742.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/21/2012 12:12 PM, Eric Dumazet wrote:
> Le mercredi 21 mars 2012 =C3=A0 11:25 +0200, Amir Vadai a =C3=A9crit =
:
>> From: Amir Vadai<amirv@mellanox.co.il>
>>
>> Set max rate-limit using sysfs file /sys/class/net/<interface>/qos/r=
atelimit
>>
>> To set, enter a space separated list of values in units of 100Mbps. =
 For
>> example to set ratelimit of 5G to TC0 and 10G for the reset on eth2 =
issue:
>> echo 50 100 100 100 100 100 100 100 100>  /sys/class/net/eth2/qos/ra=
telimit
>>
>
> Oh thats not very user friendly.
>
> I suggest one value per file (Its probably a generic /sys rule anyway=
)
> and not using 100Mps for the unit, even if it is the base granularity=
 of
> this hardware.
>
>
> /sys/class/net/eth2/qos/0/ratelimit
> ...
> /sys/class/net/eth2/qos/7/ratelimit
>
>

Ok, will change the structure to be:

/sys/class/net/eth2/qos/tc0/ratelimit
=2E..
/sys/class/net/eth2/qos/tc7/ratelimit

And use units of 1Mbps

- Amir
