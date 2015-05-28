From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: DSA and underlying 802.1Q encapsulation
Date: Thu, 28 May 2015 07:19:43 -0700
Message-ID: <556723FF.7030606@roeck-us.net>
References: <1183592753.514019.1432679397515.JavaMail.zimbra@savoirfairelinux.com> <20150526225142.GB26454@roeck-us.net> <1250227394.1145458.1432759717091.JavaMail.zimbra@savoirfairelinux.com> <556630EA.7060707@roeck-us.net> <1072166088.99991.1432820687442.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Chris Healy <cphealy@gmail.com>,
	=?UTF-8?B?SsOpcm9tZSBPdWZlbGxh?=
	<jerome.oufella@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:44994 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbbE1OTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 10:19:47 -0400
In-Reply-To: <1072166088.99991.1432820687442.JavaMail.zimbra@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2015 06:44 AM, Vivien Didelot wrote:
> Hi Guenter,
>
>>>> If yes, the dsa code may need to move the tag into the header.
>>>> If we are lucky, a call to vlan_hwaccel_push_inside() might do it.
>>>
>>> Thanks, I'm currently looking into it and doing some tests, I'm coming back to
>>> you asap.
>
> Issue fixed, thanks! vlan_hwaccel_push_inside() adds additional memmove, but
> this approach is simpler.
>
>>>> Do you have some vlan dsa code to share, by any chance ? That might
>>>> save me some time, as I am looking into it as well.
>>>
>>> Yes, I am about the send an RFC for fully integrated 802.1q VLAN support on
>>> Marvell 88E6352 devices.
>>>
>> Excellent, that is going to safe me a lot of work! If you don't mind,
>> please Cc: me as I am not subscribed to the network mailing list.
>
> My work is based on v4.1-rc3. Unfortunately the VLAN support breaks on latest
> net-next/master (e.g. NETIF_F_HW_SWITCH_OFFLOAD is removed; .ndo_bridge_setlink
> used to set tag and PVID, is moved to switchdev.)
>
> Are you willing to give it a try based on v4.1-rc3 in the meantime?
> Otherwise, I'll send the RFC as soon as the support is functional on net-next.
>

I already rebased my code to net-next, not for the switchdev changes but
to catch the dsa changes, so net-next would be much better. I'd like to get
a glance at your code, though, if that is possible.

Thanks,
Guenter
