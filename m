From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Wed, 27 Apr 2016 17:38:09 +0200
Message-ID: <5720DCE1.8060803@6wind.com>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160427095615.GA27071@breakpoint.cc>
 <20160427151336.GB1962@nanopsycho.orion>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>, Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36378 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224AbcD0PiX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 11:38:23 -0400
Received: by mail-wm0-f51.google.com with SMTP id n129so33218029wmn.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 08:38:22 -0700 (PDT)
In-Reply-To: <20160427151336.GB1962@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/04/2016 17:14, Jiri Pirko a =E9crit :
> Wed, Apr 27, 2016 at 11:56:15AM CEST, fw@strlen.de wrote:
>> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>> This patch adds the support of the 6WIND SHULTI switch. It is a sof=
tware
>>> switch doing L2 forwarding.
>>>
>>> This first version implements the minimum needed to get the device =
working.
>>> It also implements, via switchdev and rtnetlink, bridge forwarding =
offload,
>>> including FDB static entries, FDB learning and FDB ageing.
>>
>> How is this different from net/bridge?
>> How is this different from openvswitch?
>=20
> The difference is that it this tries to allow userspace crap to mirro=
r
> setting user does for bridge/ovs. Basically this looks to me like an
> attempt to enable userspace SDKs and such.
>=20
It is software switch, allowed by the switchdev model (see
Documentation/networking/switchdev.txt), same design as mellanox spectr=
um.

What's wrong with that?
