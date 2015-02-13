From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Fri, 13 Feb 2015 11:34:45 +0800
Message-ID: <54DD70D5.5050800@windriver.com>
References: <1423719323-4667-1-git-send-email-Yanjun.Zhu@windriver.com>	<1423719323-4667-2-git-send-email-Yanjun.Zhu@windriver.com> <20150212045558.5091262a@uryu.home.lan> <54DD655E.5020301@windriver.com> <54DD6EBC.2030203@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>, <mst@redhat.com>, <jasowang@redhat.com>,
	<viro@zeniv.linux.org.uk>, <davem@davemloft.net>
To: Fan Du <fengyuleidian0615@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:37800 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751839AbbBMDgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 22:36:01 -0500
In-Reply-To: <54DD6EBC.2030203@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2015 11:25 AM, Fan Du wrote:
> =E4=BA=8E 2015=E5=B9=B402=E6=9C=8813=E6=97=A5 10:45, yzhu1 =E5=86=99=E9=
=81=93:
>> On 02/12/2015 08:55 PM, Stephen Hemminger wrote:
>>> On Thu, 12 Feb 2015 13:35:23 +0800
>>> Zhu Yanjun <Yanjun.Zhu@windriver.com> wrote:
>>>
>>>> From: Zhu Yanjun <yanjun.zhu@windriver.com>
>>>>
>>>> The default speed of normal nic is 1000M while the default speed
>>>> of tun is 10M. Now the default speed of tun is changed to 1000M.
>>>> And there are 3 options: 10M, 100M and 1000M to the speed of tun.
>>>> The command "ethtool -s tun0 speed 10/100/1000" can configure the
>>>> speed of tun dynamically.
>>>>
>>>> CC: Michael S. Tsirkin <mst@redhat.com>
>>>> CC: Jason Wang <jasowang@redhat.com>
>>>> CC: Al Viro <viro@zeniv.linux.org.uk>
>>>> Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
>>>> Signed-off-by: Zhu Yanjun <Yanjun.Zhu@windriver.com>
>>> Why limit to 10/100/1000 speed?
>>> Ethtool speed can be any value
>> Thanks for your comments.
>>
>> Yes. But the real physical nic speed often 10M, 100M and 1000M.
>> This simulates the physical nic.
>    ^^^^^^^^^^^^^^^
> then a speed control logical would be needed to effect the=20
> corresponding speed
> when tun/tap gets/puts packets corresponding to the speed setting.
>
> What's the benefit when changing speed from 10Mb/s to 1000Mb/s?
>
> Just xia bibi ;)
:-P
Thanks for your reply.

This speed is just for user space application. There is no any speed=20
control logic here.:-(

Zhu Yanjun

>
>
>
>
