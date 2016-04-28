From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Thu, 28 Apr 2016 17:05:47 +0300
Message-ID: <CAJ3xEMgA8zx7nsZ0w5y4HwzrMwhXOnp1kJ_YjqTU6P5fPD+10A@mail.gmail.com>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
	<20160427095615.GA27071@breakpoint.cc>
	<20160427151336.GB1962@nanopsycho.orion>
	<20160427.125506.1088576804354580011.davem@davemloft.net>
	<5721FB26.6070305@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35221 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147AbcD1OFt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 10:05:49 -0400
Received: by mail-io0-f179.google.com with SMTP id d62so77889973iof.2
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 07:05:48 -0700 (PDT)
In-Reply-To: <5721FB26.6070305@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016, Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote=
:
> Le 27/04/2016 18:55, David Miller a =C3=A9crit :
>> From: Jiri Pirko <jiri@resnulli.us>

>>> The difference is that it this tries to allow userspace crap to mir=
ror
>>> setting user does for bridge/ovs. Basically this looks to me like a=
n
>>> attempt to enable userspace SDKs and such.

>> +1

> I don't think so because a userspace can receive all the bridge/ovs s=
ettings by
> mean of netlink mirror, without the need for this driver at all.

yep, Jiri, can you explain what's the difference in **that** aspect
(sans adding new netlinks) between the case here to the already
existing bridge/bonding (wasn't aware to the ovs ones) reflections to
user-space?

Or.
