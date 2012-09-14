From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next v2 0/1] Add support of ECMPv6
Date: Fri, 14 Sep 2012 15:37:09 +0200
Message-ID: <50533305.9070604@6wind.com>
References: <505058F5.9020707@linux-ipv6.org> <1347609548-14494-1-git-send-email-nicolas.dichtel@6wind.com> <87392l7xjc.fsf@guybrush.luffy.cx> <5053329F.6030109@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Vincent Bernat <bernat@luffy.cx>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:53052 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543Ab2INNhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 09:37:14 -0400
Received: by eaac11 with SMTP id c11so1694692eaa.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 06:37:13 -0700 (PDT)
In-Reply-To: <5053329F.6030109@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/09/2012 15:35, Nicolas Dichtel a =C3=A9crit :
> Le 14/09/2012 11:40, Vincent Bernat a =C3=A9crit :
>>   =E2=9D=A6 14 septembre 2012 09:59 CEST, Nicolas Dichtel <nicolas.d=
ichtel@6wind.com> :
>>
>>> Here is an example of a command to add an ECMP route:
>>> $ ip -6 route add 3ffe:304:124:2306::/64 \
>>>     nexthop via fe80::230:1bff:feb4:e05c dev eth0 weight 1 \
>>>     nexthop via fe80::230:1bff:feb4:dd4f dev eth0 weight 1
> In fact, I use this command as a shortcut. You can also use:
> $ ip -6 route add 3ffe:304:124:2306::/64 via fe80::230:1bff:feb4:dd4f=
 dev eth0
> $ ip -6 route append 3ffe:304:124:2406::/64 via fe80::230:1bff:feb4:d=
d4f dev eth0
Note also that with these commands, there is no need to patch iproute2.
