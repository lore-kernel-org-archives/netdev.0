From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: Re: [PATCH iproute2 net-next 2/2] iplink: bridge: add support for IFLA_BR_VLAN_FILTERING attribute
Date: Wed, 12 Aug 2015 21:42:46 +0300
Message-ID: <C6EE9E65-3C7F-4793-88ED-02E18369AA18@blackwall.org>
References: <1439297784-1962-1-git-send-email-razor@blackwall.org> <1439297784-1962-3-git-send-email-razor@blackwall.org> <20150812092132.670d0b5f@urahara>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33142 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbbHLSmy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 14:42:54 -0400
Received: by wijp15 with SMTP id p15so229369506wij.0
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 11:42:53 -0700 (PDT)
In-Reply-To: <20150812092132.670d0b5f@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 12, 2015, at 7:21 PM, Stephen Hemminger <stephen@networkplumbe=
r.org> wrote:
>=20
> On Tue, 11 Aug 2015 15:56:24 +0300
> Nikolay Aleksandrov <razor@blackwall.org> wrote:
>=20
>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>=20
>> This patch implements support for the IFLA_BR_VLAN_FILTERING attribu=
te
>> in iproute2 so it can enable/disable vlan_filtering.
>>=20
>> Example:
>> $ ip link set br0 type bridge vlan_filtering 1
>> $ ip -d link show br0
>> 6: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue sta=
te
>> UP mode DEFAULT group default
>>    link/ether 08:00:27:ea:07:38 brd ff:ff:ff:ff:ff:ff promiscuity 0
>>    bridge forward_delay 1500 hello_time 200 max_age 2000 vlan_filter=
ing 1
>>    addrgenmode eui64
>>=20
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>=20
> Applied.
> Please update man page as well.

Hi Stephen,
I looked into the man page update while making the patch but I didn=E2=80=
=99t find bridge specific attributes anywhere and
so I thought that section hasn=E2=80=99t been added yet. Anyway, I have=
 plans to add it and describe all of the currently
supported attributes plus the ones I plan to post patches for soon.

Cheers,
 Nik