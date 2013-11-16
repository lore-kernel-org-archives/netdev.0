From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net] bonding: don't change to 802.3ad mode while ARP monitor
 is running
Date: Sat, 16 Nov 2013 09:52:08 +0800
Message-ID: <5286CFC8.4070008@gmail.com>
References: <5285F12A.6030307@huawei.com> <20131115.204042.1434943107870815286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dingtianhong@huawei.com, fubar@us.ibm.com, andy@greyhouse.net,
	nikolay@redhat.com, vfalico@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:65057 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923Ab3KPCDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 21:03:01 -0500
Received: by mail-pb0-f47.google.com with SMTP id rr4so2872888pbb.20
        for <netdev@vger.kernel.org>; Fri, 15 Nov 2013 18:03:00 -0800 (PST)
In-Reply-To: <20131115.204042.1434943107870815286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/16 9:40, David Miller =E5=86=99=E9=81=93:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Fri, 15 Nov 2013 18:02:18 +0800
>
>> Because the ARP monitor is not support for 802.3ad, but We still
>                                   ^^^^^^^
>
> "supported"
>
> No need to capitalize "We".
>
>> could change the mode to 802.3ad from ab mode while ARP monirot
>                                                            ^^^^^^^
>
> "monitor"
>
>> is running, it is incorrect.
>>
>> So add a check for 802.3ad in bonding_store_mode to fix the problem,
>> and make a micro program to simplify the code.
> What is a "micro program"?

sorry, not review the changelog yet,I will resend it and it will not be=
=20
happend again.
Regards

Ding

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
