From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] iplink: allow to show ip addresses
Date: Wed, 26 Nov 2014 15:00:52 +0100
Message-ID: <5475DD14.7050206@6wind.com>
References: <1416847337-23661-1-git-send-email-nicolas.dichtel@6wind.com>	<20141125061023.GA8819@unicorn.suse.cz> <20141126141204.42c76a37@griffin>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>, Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:57811 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826AbaKZOA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 09:00:58 -0500
Received: by mail-wi0-f180.google.com with SMTP id n3so5066152wiv.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 06:00:56 -0800 (PST)
In-Reply-To: <20141126141204.42c76a37@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/11/2014 14:12, Jiri Benc a =E9crit :
> On Tue, 25 Nov 2014 07:10:23 +0100, Michal Kubecek wrote:
>> On Mon, Nov 24, 2014 at 05:42:17PM +0100, Nicolas Dichtel wrote:
>>> This patch adds a new option (-addresses) to the 'ip link' command =
so that the
>>> user can display link details and IP addresses with the same comman=
d.
>>>
>>> Example:
>>> $ ip -d -a l ls gre1
>>> 9: gre1@NONE: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1468 qdisc noqueu=
e state UNKNOWN mode DEFAULT group default
>>>      link/gre 10.16.0.249 peer 10.16.0.121 promiscuity 0
>>>      gre remote 10.16.0.121 local 10.16.0.249 ttl inherit ikey 0.0.=
0.10 okey 0.0.0.10 icsum ocsum
>>>      inet 192.168.0.249 peer 192.168.0.121/32 scope global gre1
>>>         valid_lft forever preferred_lft forever
>>>      inet6 fe80::5efe:a10:f9/64 scope link
>>>         valid_lft forever preferred_lft forever
>>
>> Perhaps it would be more consistent to add -d option to "ip addr sho=
w"
>> instead as we already have -s for statistics there (commit 5d5cf1b43=
).
>
> Agreed.
I also agree ;-)
Will send a v2.


Thank you,
Nicolas
