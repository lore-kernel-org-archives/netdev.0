From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] pktgen: Clone skb to avoid corruption of skbs in ndo_start_xmit
 methods
Date: Tue, 19 Jul 2011 14:01:23 -0700
Message-ID: <4E25F0A3.8020509@candelatech.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com>	 <1311105738.3113.11.camel@edumazet-laptop>	 <20110719202922.GA2352@minipsycho> <1311108107.3113.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35271 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751602Ab1GSVBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2011 17:01:45 -0400
In-Reply-To: <1311108107.3113.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/19/2011 01:41 PM, Eric Dumazet wrote:
> Le mardi 19 juillet 2011 =C3=A0 22:29 +0200, Jiri Pirko a =C3=A9crit =
:
>
>> You are right, but it may not cause panic, right? In case this patch
>> would cause significant performance regression, how about to just fo=
rbid
>> pktgen to run on soft-netdevs ?
>>
>
> Please do

No, please do not.  Pktgen *can* work on soft-devs if you do not
use multi-skb, and it can be useful for testing highs speed vlan
traffic and various other things.

If you must, forbid multi-skb on soft devices, but don't just
break pktgen for all soft-devices.

Thanks,
Ben

>
> Note : a sysadmin has other ways to make a machine panic or reboot or
> halt...
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

