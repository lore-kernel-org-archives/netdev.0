From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Wed, 27 Apr 2016 17:54:46 +0200
Message-ID: <20160427155446.GD1962@nanopsycho.orion>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160427095615.GA27071@breakpoint.cc>
 <20160427151336.GB1962@nanopsycho.orion>
 <5720DCE1.8060803@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Westphal <fw@strlen.de>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33902 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468AbcD0Pyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 11:54:49 -0400
Received: by mail-wm0-f47.google.com with SMTP id v200so28941005wmv.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 08:54:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5720DCE1.8060803@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 27, 2016 at 05:38:09PM CEST, nicolas.dichtel@6wind.com wrote:
>Le 27/04/2016 17:14, Jiri Pirko a =E9crit :
>> Wed, Apr 27, 2016 at 11:56:15AM CEST, fw@strlen.de wrote:
>>> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>>>> This patch adds the support of the 6WIND SHULTI switch. It is a so=
ftware
>>>> switch doing L2 forwarding.
>>>>
>>>> This first version implements the minimum needed to get the device=
 working.
>>>> It also implements, via switchdev and rtnetlink, bridge forwarding=
 offload,
>>>> including FDB static entries, FDB learning and FDB ageing.
>>>
>>> How is this different from net/bridge?
>>> How is this different from openvswitch?
>>=20
>> The difference is that it this tries to allow userspace crap to mirr=
or
>> setting user does for bridge/ovs. Basically this looks to me like an
>> attempt to enable userspace SDKs and such.
>>=20
>It is software switch, allowed by the switchdev model (see
>Documentation/networking/switchdev.txt), same design as mellanox spect=
rum.

Switchdev purpose is to offload stuff down to HW.
You say your switch is software, so integrate it properly into kernel.
Easy.


>
>What's wrong with that?

What's wrong is that your driver allows many userspace proprietary SDKs
to work on out-of-box kernel. This is called "trampoline model". You
basically enable userspace drivers for switches and stuff like that.
This was discussed many many times.
