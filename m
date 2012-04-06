From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH net-next] rps: introduce a new sysctl switch rps_workaround_buggy_driver
Date: Fri, 06 Apr 2012 10:07:09 +0800
Message-ID: <4F7E4FCD.7050501@gmail.com>
References: <4F7D7464.7040503@gmail.com> <1333624027.18626.579.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63052 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab2DFCHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 22:07:25 -0400
Received: by iagz16 with SMTP id z16so2548314iag.19
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 19:07:24 -0700 (PDT)
In-Reply-To: <1333624027.18626.579.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B404=E6=9C=8805=E6=97=A5 19:07, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Thu, 2012-04-05 at 18:31 +0800, Li Yu wrote:
>> We encountered a buggy NIC driver or hardware/firmware, it keeps
>> non-zero constant skb->rxhash for long time, so if we enabled RPS,
>> the targeted CPU keeps same for long time too.
>>
>> This patch introduces a sysctl switch to workaround for such problem=
,
>> if the switch was on, RPS core discards the skb->rxhash that is
>> computed by NIC hardware.
>>
>> Hope this patch also can help others, thanks.
>
> Really ?
>
> to disable this driver rxhash, you should try :
>
> ethtool -K eth0 rxhash off
>
>

Great! I really did not know this new option ago,
and wrote a kprobe workaround module. It seem that
ethtool 2.6.39 have such support at least.

Thank you very much!

Yu

>
>
