From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Sun, 1 May 2016 21:53:57 +0200
Message-ID: <20160501195356.GC1947@nanopsycho.orion>
References: <20160427151336.GB1962@nanopsycho.orion>
 <20160427.125506.1088576804354580011.davem@davemloft.net>
 <5721FB26.6070305@6wind.com>
 <20160428.115419.1831238411921569629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36294 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394AbcEATyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 15:54:00 -0400
Received: by mail-wm0-f65.google.com with SMTP id w143so14340524wmw.3
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 12:53:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160428.115419.1831238411921569629.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 28, 2016 at 05:54:19PM CEST, davem@davemloft.net wrote:
>From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>Date: Thu, 28 Apr 2016 13:59:34 +0200
>
>> Le 27/04/2016 18:55, David Miller a =E9crit :
>>> From: Jiri Pirko <jiri@resnulli.us>
>> [snip]
>>>> The difference is that it this tries to allow userspace crap to mi=
rror
>>>> setting user does for bridge/ovs. Basically this looks to me like =
an
>>>> attempt to enable userspace SDKs and such.
>>>=20
>>> +1
>> I don't think so because a userspace can receive all the bridge/ovs =
settings by
>> mean of netlink mirror, without the need for this driver at all.
>
>You can say whatever you want, but the facilities you are adding to
>this driver enables proprietary userland SDK components.
>
>And this is precisely what we are trying to avoid by having a clean,
>fully featured switch device model in the kernel.
>
>It is against your interestes of upstreaming your driver to continue
>denying what your changes facilitate.

+1

Nicolas, your driver is big a step back. Just do what you need to do,
properly, in kernel. There's a lot of people to help you with that
around.
