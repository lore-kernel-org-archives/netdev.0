From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Wed, 19 Aug 2015 14:48:18 +0200
Message-ID: <8737zf8mwd.fsf@zoro.exoscale.ch>
References: <87fv3ier4s.fsf@zoro.exoscale.ch>
	<1439966648-26195-1-git-send-email-vincent@bernat.im>
	<1439966648-26195-2-git-send-email-vincent@bernat.im>
	<20150819130013.1a847627@griffin> <87bne38oj7.fsf@zoro.exoscale.ch>
	<20150819143800.6863fa3b@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:40076 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753789AbbHSMsV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 08:48:21 -0400
In-Reply-To: <20150819143800.6863fa3b@griffin> (Jiri Benc's message of "Wed,
	19 Aug 2015 14:38:00 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 19 ao=C3=BBt 2015 14:38 +0200, Jiri Benc <jbenc@redhat.com>=C2=
=A0:

>> That's the main goal of this patch: advertising the peer link as
>> IFLA_LINK attribute triggers an infinite loop in userland software w=
hen
>> they follow iflink to discover network devices topology. iflink has
>> always been the index of a lower device. If a sysfs symbolic link is=
 not
>> good enough, I can propose a new IFLA_PEER attribute instead.
>
> This would cause regression and break applications for those of us wh=
o
> started relying on the netnsid feature to match interfaces across net
> name spaces.

Yes. Unfortunately.

> This is tough. If you're going to do such thing, you would at least
> need to also introduce IFLA_PEER_NETNSID.

Yes I can.

In my opinion, the change of semantics of IFLA_LINK is a break of
API. However, I can live with it since it's easy to workaround it. It
just seemed easier to start the discussion with a patch.
--=20
Parenthesise to avoid ambiguity.
            - The Elements of Programming Style (Kernighan & Plauger)
