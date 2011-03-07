From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/2] Issue NETDEV_CHANGE notification when bridge changes
 state
Date: Mon, 07 Mar 2011 08:44:03 +0100
Message-ID: <4D748CC3.8060603@gmail.com>
References: <1649722795.14144.1299480074110.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adam Majer <adamm@zombino.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42923 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160Ab1CGHoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 02:44:06 -0500
Received: by wwb22 with SMTP id 22so4871826wwb.1
        for <netdev@vger.kernel.org>; Sun, 06 Mar 2011 23:44:05 -0800 (PST)
In-Reply-To: <1649722795.14144.1299480074110.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 07/03/2011 07:41, Stephen Hemminger a =C3=A9crit :
>
>> On Sun, Mar 06, 2011 at 09:45:41AM -0800, Stephen Hemminger wrote:
>>> Since this a generic problem, it needs a better solution.
>>> Sending NETDEV_CHANGE impacts lots of other pieces, and even
>>> user space has similar problems.
>>
>> It does seem a little broad notification type. I've checked over
>> all the currently defined NETDEV notifiers, and it seems that
>> NETDEV_NOTIFY_PEERS may be a better option to use when bridge
>> has a potential topology change.
>>
>> Currently it is only used in ipv4/devinet.c: where it is used to iss=
ue
>> a gratuitous ARP.
>
> I was thinking of fixing bridge to not actually bring the link
> up until in forwarding mode. Other applications (DHCP, etc)
> see the link up and really don't like being in half duplex
> during that period.

I think it is the right way to manage this situation. And bonding shoul=
d behave the same, if not=20
already true.

	Nicolas.
