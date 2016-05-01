From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] drivers/net: add 6WIND SHULTI support
Date: Sun, 1 May 2016 17:24:43 +0200
Message-ID: <20160501152443.GA1947@nanopsycho.orion>
References: <1461749838-4613-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160427095615.GA27071@breakpoint.cc>
 <20160427151336.GB1962@nanopsycho.orion>
 <20160427.125506.1088576804354580011.davem@davemloft.net>
 <5721FB26.6070305@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35940 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399AbcEAPYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2016 11:24:46 -0400
Received: by mail-wm0-f65.google.com with SMTP id w143so13668266wmw.3
        for <netdev@vger.kernel.org>; Sun, 01 May 2016 08:24:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5721FB26.6070305@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 28, 2016 at 01:59:34PM CEST, nicolas.dichtel@6wind.com wrote:
>Le 27/04/2016 18:55, David Miller a =E9crit :
>> From: Jiri Pirko <jiri@resnulli.us>
>[snip]
>>> The difference is that it this tries to allow userspace crap to mir=
ror
>>> setting user does for bridge/ovs. Basically this looks to me like a=
n
>>> attempt to enable userspace SDKs and such.
>>=20
>> +1
>I don't think so because a userspace can receive all the bridge/ovs se=
ttings by
>mean of netlink mirror, without the need for this driver at all.

Okay, so what is the different is your words? I asked about purpose and
userspace for this "driver", but you didn't provide that.

I see what I see.

Also, if you say you don't need this driver at all, why are you pushing
it? Userspace apps can glean on netlink messages and act accordingly. I=
n
fact, this is what people are doing (for example Cumulus).

I must be missing something there... (unfortunatelly, I'm pretty sure I=
'm not).
