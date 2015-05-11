From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: Remove remaining remnants of pm_qos from netdevice.h
Date: Mon, 11 May 2015 11:27:22 -0600
Message-ID: <5550E67A.4070907@gmail.com>
References: <1431210103-18683-1-git-send-email-dsahern@gmail.com>	<20150511.131106.1902675173206646881.davem@davemloft.net> <20150511.132611.701878238281798138.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33310 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751373AbbEKR1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 13:27:23 -0400
Received: by iepj10 with SMTP id j10so110514090iep.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 10:27:23 -0700 (PDT)
In-Reply-To: <20150511.132611.701878238281798138.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/15 11:26 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 11 May 2015 13:11:06 -0400 (EDT)
>
>> From: David Ahern <dsahern@gmail.com>
>> Date: Sat,  9 May 2015 16:21:43 -0600
>>
>>> Commit e2c6544829f removed pm_qos from struct net_device but left t=
he
>>> comment above header file. Remove those.
>>>
>>> Signed-off-by: David Ahern <dsahern@gmail.com>
>>
>> Applied, thanks David.
>
> Actually I had to revert as this breaks the build.
>
> You will need to submit another patch with this one, one that adds an
> include of <linux/pm_qos.h> to drivers/net/ethernet/intel/e1000e/e100=
0.h
>
> In file included from drivers/net/ethernet/intel/e1000e/82571.c:38:0:
> drivers/net/ethernet/intel/e1000e/e1000.h:346:24: error: field =A1pm_=
qos_req=A2 has incomplete type
>    struct pm_qos_request pm_qos_req;
>                          ^
>

crap. I did a VM build with virtio only. Will redo.

David
