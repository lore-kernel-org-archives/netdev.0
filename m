From: Duan Jiong <djduanjiong@gmail.com>
Subject: Re: [PATCH ] ipv6: handle the update of the NDISC_REDIRECT error
 code in icmpv6_err_convert
Date: Thu, 19 Sep 2013 13:24:04 +0800
Message-ID: <523A8A74.30005@gmail.com>
References: <523996E0.9080702@cn.fujitsu.com> <20130918.123613.61436246160249555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46789 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083Ab3ISFYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 01:24:09 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so7887688pbb.5
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 22:24:08 -0700 (PDT)
In-Reply-To: <20130918.123613.61436246160249555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/9/19 0:36, David Miller =E5=86=99=E9=81=93:
> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> Date: Wed, 18 Sep 2013 20:04:48 +0800
>
>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>
>> when dealing with redirect message in udpv6_err() and
>> rawv6_err() the err shoud be assigned to 0, not EPROTO.
>>
>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
> No, you should fix this the same way you handled DCCP, but skipping
> the whole socket error setting path for NDISC_REDIRECT.

Your meaning is that we should return directly after calling
ip6_sk_redirect(), is that it?

Thanks,
   Duan


> Clearing the socket error to zero is not correct, it means you will
> lose any existing error setting.
