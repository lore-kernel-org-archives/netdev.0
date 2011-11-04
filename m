From: Kevin Wilson <wkevils@gmail.com>
Subject: Re: iproute2 neighboring
Date: Fri, 4 Nov 2011 21:27:39 +0200
Message-ID: <CAGXs5wW_5M4cZQdZoCUgGTTOW5ZEhpWY2p235dBbk_SF1BznfQ@mail.gmail.com>
References: <CAGXs5wUEiS-vpdsCDoyva2Vg9XKBmbJgoPVOXUXD0u9+PzXH=w@mail.gmail.com>
	<OFD3A98142.1EDCCB6F-ON8825793E.0055C070-8825793E.0056A45E@us.ibm.com>
	<1320422044.81742.YahooMailNeo@web126019.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: =?ISO-8859-1?Q?Fran=E7ois=2DXavier_Le_Bail?= <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:36370 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab1KDT1k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 15:27:40 -0400
In-Reply-To: <1320422044.81742.YahooMailNeo@web126019.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Thanks all responses!
The answer that there is a fixed mapping in case of multicast is reason=
able,
and I assume this is the reason for not seeing multicast addresses in
neigh table.
>You can also see group memberships with "ip m".
I wonder whether I can know from "ip -m" which multicast addresses
are attached to which ip addresses.
=46or example,
"ip -m" shows:
2:	em1
=2E..     ip1
=2E..     ip2
=2E..     ip3
	inet  224.0.0.1
	inet6 ff02::1:ffcf:c821
	inet6 ff02::1

is the order important here?
namely, is  ip1 belongs to  224.0.0.1,
ip2 belongs to ff02::1:ffcf:c821, and ip3 belong to ff02::1?

rgs,
Kevin


2011/11/4 Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>:
>
>
>
>
> ----- Original Message -----
>> From: David Stevens <dlstevens@us.ibm.com>
>> To: Kevin Wilson <wkevils@gmail.com>
>> Cc: netdev@vger.kernel.org; netdev-owner@vger.kernel.org
>> Sent: Friday, November 4, 2011 4:46 PM
>> Subject: Re: iproute2 neighboring
>>
>>> =A0From: Kevin Wilson <wkevils@gmail.com>
>>
>>> =A0Hi,
>>> =A0It seems to me that "ip -6 neigh show" does not show multicast
>> entries
>> from
>>> =A0IPv6 neighboring=A0 table. Is there a reason for this ?
>>
>> Multicast memberships aren't in the neighbor table. The
>> neighbor table is for translating protocol addresses to
>> MAC addresses and that translation is fixed for multicast
>> destinations.
>>
>> You can see group memberships with "netstat -g". There are also
>> some data in /proc/net/{dev_mcast,igmp6,mcfilter6} depending on
>> what you're looking for.
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 +-DLS
>
> Hi,
>
> You can also see group memberships with "ip m".
>
> Fran=E7ois-Xavier
>
>
